import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';
import '../models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return AuthRepositoryImpl(remoteDataSource, secureStorage);
});

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorage;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl(
    this._remoteDataSource,
    this._secureStorage, {
    GoogleSignIn? googleSignIn,
  }) : _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential =
          await fb.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        return const Left(
            AuthFailure('Gagal mendapatkan token autentikasi Firebase.'));
      }

      return await loginWithFirebaseToken(idToken);
    } on fb.FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthErrorCode(e.code)));
    } catch (e) {
      return Left(AuthFailure('Terjadi kesalahan saat masuk: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const Left(
            AuthFailure('Login Google dibatalkan oleh pengguna.'));
      }

      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await fb.FirebaseAuth.instance.signInWithCredential(credential);
      final idToken = await userCredential.user?.getIdToken();

      if (idToken == null || idToken.isEmpty) {
        return const Left(
            AuthFailure('Gagal mendapatkan token autentikasi dari Google.'));
      }

      return await loginWithFirebaseToken(idToken);
    } on fb.FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthErrorCode(e.code)));
    } catch (e) {
      return Left(AuthFailure(
          'Terjadi kesalahan saat masuk dengan Google: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> loginWithFirebaseToken(
      String firebaseIdToken) async {
    try {
      final response =
          await _remoteDataSource.loginWithFirebaseToken(firebaseIdToken);
      final data = response['data'] as Map<String, dynamic>;

      final token = data['token'] as String;
      final userJson = data['user'] as Map<String, dynamic>;

      final userModel = UserModel.fromJson(userJson);

      await _secureStorage.saveToken(token);
      await _secureStorage.saveUserData(userJson);

      return Right(userModel.toEntity());
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      return Left(ServerFailure(
        apiException.message,
        statusCode: apiException.statusCode,
        errors: apiException.errors,
      ));
    } catch (e) {
      return Left(
          AuthFailure('Gagal menukarkan token dengan server: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null || token.isEmpty) {
        return const Left(AuthFailure('Sesi tidak ditemukan.'));
      }

      final cachedUser = await _secureStorage.getUserData();
      if (cachedUser != null) {
        return Right(UserModel.fromJson(cachedUser).toEntity());
      }

      final userModel = await _remoteDataSource.getCurrentUser();
      await _secureStorage.saveUserData(userModel.toJson());
      return Right(userModel.toEntity());
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      if (apiException.statusCode == 401) {
        await _secureStorage.clearAll();
      }
      return Left(ServerFailure(
        apiException.message,
        statusCode: apiException.statusCode,
        errors: apiException.errors,
      ));
    } catch (e) {
      return Left(
          AuthFailure('Gagal mengambil data pengguna: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {}

    try {
      await fb.FirebaseAuth.instance.signOut();
    } catch (_) {}

    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    await _secureStorage.clearAll();
    return const Right(null);
  }

  String _mapFirebaseAuthErrorCode(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-disabled':
        return 'Akun pengguna telah dinonaktifkan.';
      case 'network-request-failed':
        return 'Koneksi ke server gagal. Periksa jaringan internet Anda.';
      default:
        return 'Gagal autentikasi Firebase. Silakan coba lagi.';
    }
  }
}
