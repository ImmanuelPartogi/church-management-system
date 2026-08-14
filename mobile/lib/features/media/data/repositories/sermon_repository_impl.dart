import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/sermon.dart';
import '../../domain/repositories/sermon_repository.dart';
import '../datasource/sermon_remote_datasource.dart';

final sermonRepositoryProvider = Provider<SermonRepository>((ref) {
  final remoteDataSource = ref.watch(sermonRemoteDataSourceProvider);
  return SermonRepositoryImpl(remoteDataSource);
});

class SermonRepositoryImpl implements SermonRepository {
  final SermonRemoteDataSource _remoteDataSource;

  SermonRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Sermon>>> getSermons({
    String? search,
    int page = 1,
  }) async {
    try {
      final models = await _remoteDataSource.getSermons(
        search: search,
        page: page,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      return Left(
        ServerFailure(
          apiException.message,
          statusCode: apiException.statusCode,
        ),
      );
    } catch (e) {
      return Left(
        ServerFailure('Gagal memuat arsip khotbah: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Sermon>> getSermonDetail(int id) async {
    try {
      final model = await _remoteDataSource.getSermonDetail(id);
      return Right(model.toEntity());
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      return Left(
        ServerFailure(
          apiException.message,
          statusCode: apiException.statusCode,
        ),
      );
    } catch (e) {
      return Left(
        ServerFailure('Gagal memuat detail khotbah: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, int>> downloadSermon(int id) async {
    try {
      final count = await _remoteDataSource.downloadSermon(id);
      return Right(count);
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      return Left(
        ServerFailure(
          apiException.message,
          statusCode: apiException.statusCode,
        ),
      );
    } catch (e) {
      return Left(
        ServerFailure('Gagal mencatat unduhan khotbah: ${e.toString()}'),
      );
    }
  }
}
