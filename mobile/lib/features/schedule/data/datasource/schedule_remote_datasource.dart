import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/worship_schedule_model.dart';

final scheduleRemoteDataSourceProvider =
    Provider<ScheduleRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return ScheduleRemoteDataSource(dio);
});

class ScheduleRemoteDataSource {
  final Dio _dio;

  ScheduleRemoteDataSource(this._dio);

  Future<List<WorshipScheduleModel>> getWorshipSchedules() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.worshipSchedulesEndpoint,
    );
    final json = response.data as Map<String, dynamic>;
    final list = json['data'] as List<dynamic>;

    return list
        .map((item) =>
            WorshipScheduleModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, List<WorshipScheduleModel>>>
      getWorshipScheduleCalendar() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.worshipSchedulesCalendarEndpoint,
    );
    final json = response.data as Map<String, dynamic>;
    final dataMap = json['data'] as Map<String, dynamic>;

    final resultMap = <String, List<WorshipScheduleModel>>{};
    dataMap.forEach((day, items) {
      final itemList = (items as List<dynamic>)
          .map((item) =>
              WorshipScheduleModel.fromJson(item as Map<String, dynamic>))
          .toList();
      resultMap[day] = itemList;
    });

    return resultMap;
  }
}
