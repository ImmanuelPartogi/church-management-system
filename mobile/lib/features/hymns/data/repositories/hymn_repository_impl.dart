import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/song.dart';
import '../../domain/entities/songbook.dart';
import '../../domain/repositories/hymn_repository.dart';
import '../datasource/hymn_remote_datasource.dart';

final hymnRepositoryProvider = Provider<HymnRepository>((ref) {
  final remoteDataSource = ref.watch(hymnRemoteDataSourceProvider);
  return HymnRepositoryImpl(remoteDataSource);
});

class HymnRepositoryImpl implements HymnRepository {
  final HymnRemoteDataSource _remoteDataSource;

  HymnRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Songbook>>> getSongbooks() async {
    try {
      final models = await _remoteDataSource.getSongbooks();
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
        ServerFailure('Gagal mengambil daftar buku nyanyian: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Song>>> getSongs({
    String? search,
    int? songbookId,
    int page = 1,
  }) async {
    try {
      final models = await _remoteDataSource.getSongs(
        search: search,
        songbookId: songbookId,
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
        ServerFailure('Gagal mengambil daftar lagu: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Song>> getSongDetail(int id) async {
    try {
      final model = await _remoteDataSource.getSongDetail(id);
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
        ServerFailure('Gagal mengambil detail lagu: ${e.toString()}'),
      );
    }
  }
}
