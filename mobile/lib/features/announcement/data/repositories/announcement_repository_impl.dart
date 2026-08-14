import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_exception.dart';
import '../datasource/announcement_remote_datasource.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  final remoteDataSource = ref.watch(announcementRemoteDataSourceProvider);
  return AnnouncementRepositoryImpl(remoteDataSource);
});

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  final AnnouncementRemoteDataSource _remoteDataSource;

  AnnouncementRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Announcement>>> getAnnouncements(
      {int page = 1,}) async {
    try {
      final models = await _remoteDataSource.getAnnouncements(page: page);
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      return Left(ServerFailure(
        apiException.message,
        statusCode: apiException.statusCode,
      ),);
    } catch (e) {
      return Left(
          ServerFailure('Gagal mengambil daftar pengumuman: ${e.toString()}'),);
    }
  }
}
