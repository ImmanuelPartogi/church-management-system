import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/prayer_request_model.dart';

final prayerRequestRemoteDataSourceProvider =
    Provider<PrayerRequestRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return PrayerRequestRemoteDataSource(dio);
});

class PrayerRequestRemoteDataSource {
  final Dio _dio;

  PrayerRequestRemoteDataSource(this._dio);

  Future<List<PrayerRequestModel>> getMyPrayerRequests({
    int page = 1,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.prayerRequestsEndpoint,
      queryParameters: {'page': page},
    );
    final json = response.data as Map<String, dynamic>;
    final list = json['data'] as List<dynamic>;

    return list
        .map(
          (item) => PrayerRequestModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<PrayerRequestModel> getPrayerRequestDetail(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.prayerRequestDetailEndpoint(id),
    );
    final json = response.data as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>;

    return PrayerRequestModel.fromJson(data);
  }

  Future<PrayerRequestModel> submitPrayerRequest({
    required String title,
    required String content,
    String? category,
    bool isPrivate = true,
  }) async {
    final payload = <String, dynamic>{
      'title': title,
      'content': content,
      'is_private': isPrivate,
    };

    if (category != null && category.isNotEmpty) {
      payload['category'] = category;
    }

    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.prayerRequestsEndpoint,
      data: payload,
    );

    final json = response.data as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>;

    return PrayerRequestModel.fromJson(data);
  }
}
