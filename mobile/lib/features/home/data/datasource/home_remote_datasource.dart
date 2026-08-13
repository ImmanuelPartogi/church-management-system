import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/daily_verse_model.dart';

final homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return HomeRemoteDataSource(dio);
});

class HomeRemoteDataSource {
  final Dio _dio;

  HomeRemoteDataSource(this._dio);

  Future<DailyVerseModel> getDailyVerse() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.dailyVerseEndpoint,
    );
    final json = response.data as Map<String, dynamic>;
    return DailyVerseModel.fromJson(json['data'] as Map<String, dynamic>);
  }
}
