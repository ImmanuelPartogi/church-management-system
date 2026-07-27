import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

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

  AuthRepositoryImpl(this._remoteDataSource, this._secureStorage);

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

      // Save token and user data in local secure storage
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
      return Left(AuthFailure('Terjadi kesalahan saat masuk: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // First try to load from local cache if we already have it
      final cachedUser = await _secureStorage.getUserData();
      if (cachedUser != null) {
        return Right(UserModel.fromJson(cachedUser).toEntity());
      }

      // If not, fetch from remote
      final userModel = await _remoteDataSource.getCurrentUser();
      await _secureStorage.saveUserData(userModel.toJson());
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
          AuthFailure('Gagal mengambil data pengguna: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
      await _secureStorage.clearAll();
      return const Right(null);
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      // Clean up storage anyway
      await _secureStorage.clearAll();
      return Left(ServerFailure(
        apiException.message,
        statusCode: apiException.statusCode,
        errors: apiException.errors,
      ));
    } catch (e) {
      await _secureStorage.clearAll();
      return Left(AuthFailure('Gagal keluar dari sesi: ${e.toString()}'));
    }
  }
}
