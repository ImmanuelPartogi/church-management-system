import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/worship_schedule.dart';

abstract class ScheduleRepository {
  Future<Either<Failure, List<WorshipSchedule>>> getWorshipSchedules();
  Future<Either<Failure, Map<String, List<WorshipSchedule>>>>
      getWorshipScheduleCalendar();
}
