import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/warta.dart';
import '../../domain/repositories/warta_repository.dart';
import '../datasource/warta_remote_datasource.dart';

final wartaRepositoryProvider = Provider<WartaRepository>((ref) {
  final remoteDataSource = ref.watch(wartaRemoteDataSourceProvider);
  return WartaRepositoryImpl(remoteDataSource);
});

class WartaRepositoryImpl implements WartaRepository {
  final WartaRemoteDataSource _remoteDataSource;

  WartaRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Warta>>> getWartas({int page = 1}) async {
    try {
      final models = await _remoteDataSource.getWartas(page: page);
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      return Left(ServerFailure(
        apiException.message,
        statusCode: apiException.statusCode,
      ),);
    } catch (e) {
      return Left(
          ServerFailure('Gagal mengambil daftar warta: ${e.toString()}'),);
    }
  }

  @override
  Future<Either<Failure, Warta>> getWartaDetail(int id) async {
    try {
      final model = await _remoteDataSource.getWarta(id);
      return Right(model.toEntity());
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      return Left(ServerFailure(
        apiException.message,
        statusCode: apiException.statusCode,
      ),);
    } catch (e) {
      return Left(
          ServerFailure('Gagal mengambil detail warta: ${e.toString()}'),);
    }
  }

  @override
  Future<Either<Failure, File>> downloadWarta(
    int id,
    String savePath, {
    void Function(int count, int total)? onProgress,
  }) async {
    try {
      await _remoteDataSource.downloadWarta(
        id,
        savePath,
        onReceiveProgress: onProgress,
      );
      final file = File(savePath);
      if (await file.exists()) {
        return Right(file);
      } else {
        return const Left(ServerFailure(
          'File hasil download tidak ditemukan di penyimpanan.',
        ),);
      }
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      return Left(ServerFailure(
        apiException.message,
        statusCode: apiException.statusCode,
      ),);
    } catch (e) {
      return Left(ServerFailure('Gagal mengunduh warta: ${e.toString()}'));
    }
  }
}
