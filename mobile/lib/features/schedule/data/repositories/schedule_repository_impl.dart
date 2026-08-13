import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_exception.dart';
import '../datasource/schedule_remote_datasource.dart';
import '../../domain/entities/worship_schedule.dart';
import '../../domain/repositories/schedule_repository.dart';

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  final remoteDataSource = ref.watch(scheduleRemoteDataSourceProvider);
  return ScheduleRepositoryImpl(remoteDataSource);
});

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleRemoteDataSource _remoteDataSource;

  ScheduleRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<WorshipSchedule>>> getWorshipSchedules() async {
    try {
      final models = await _remoteDataSource.getWorshipSchedules();
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      return Left(ServerFailure(
        apiException.message,
        statusCode: apiException.statusCode,
      ));
    } catch (e) {
      return Left(
          ServerFailure('Gagal mengambil jadwal ibadah: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, List<WorshipSchedule>>>>
      getWorshipScheduleCalendar() async {
    try {
      final mapModel = await _remoteDataSource.getWorshipScheduleCalendar();
      final resultMap = <String, List<WorshipSchedule>>{};
      mapModel.forEach((day, models) {
        resultMap[day] = models.map((m) => m.toEntity()).toList();
      });
      return Right(resultMap);
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      return Left(ServerFailure(
        apiException.message,
        statusCode: apiException.statusCode,
      ));
    } catch (e) {
      return Left(
          ServerFailure('Gagal mengambil kalender ibadah: ${e.toString()}'));
    }
  }
}
