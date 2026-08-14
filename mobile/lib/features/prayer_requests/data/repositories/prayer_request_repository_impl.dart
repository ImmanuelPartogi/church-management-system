import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/prayer_request.dart';
import '../../domain/repositories/prayer_request_repository.dart';
import '../datasource/prayer_request_remote_datasource.dart';

final prayerRequestRepositoryProvider =
    Provider<PrayerRequestRepository>((ref) {
  final remoteDataSource = ref.watch(prayerRequestRemoteDataSourceProvider);
  return PrayerRequestRepositoryImpl(remoteDataSource);
});

class PrayerRequestRepositoryImpl implements PrayerRequestRepository {
  final PrayerRequestRemoteDataSource _remoteDataSource;

  PrayerRequestRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<PrayerRequest>>> getMyPrayerRequests({
    int page = 1,
  }) async {
    try {
      final models = await _remoteDataSource.getMyPrayerRequests(page: page);
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
        ServerFailure(
          'Gagal mengambil daftar permohonan doa: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, PrayerRequest>> getPrayerRequestDetail(int id) async {
    try {
      final model = await _remoteDataSource.getPrayerRequestDetail(id);
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
        ServerFailure(
          'Gagal mengambil detail permohonan doa: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, PrayerRequest>> submitPrayerRequest({
    required String title,
    required String content,
    String? category,
    bool isPrivate = true,
  }) async {
    try {
      final model = await _remoteDataSource.submitPrayerRequest(
        title: title,
        content: content,
        category: category,
        isPrivate: isPrivate,
      );
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
        ServerFailure(
          'Gagal mengirimkan permohonan doa: ${e.toString()}',
        ),
      );
    }
  }
}
