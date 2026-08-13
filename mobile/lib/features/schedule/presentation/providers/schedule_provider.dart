import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/schedule_repository_impl.dart';
import '../../domain/entities/worship_schedule.dart';

final scheduleListProvider = FutureProvider<List<WorshipSchedule>>((ref) async {
  final repository = ref.watch(scheduleRepositoryProvider);
  final result = await repository.getWorshipSchedules();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (schedules) => schedules,
  );
});
