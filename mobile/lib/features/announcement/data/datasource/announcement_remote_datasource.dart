import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/announcement_model.dart';

final announcementRemoteDataSourceProvider =
    Provider<AnnouncementRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return AnnouncementRemoteDataSource(dio);
});

class AnnouncementRemoteDataSource {
  final Dio _dio;

  AnnouncementRemoteDataSource(this._dio);

  Future<List<AnnouncementModel>> getAnnouncements({int page = 1}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.announcementsEndpoint,
      queryParameters: {'page': page},
    );
    final json = response.data as Map<String, dynamic>;
    final list = json['data'] as List<dynamic>;

    return list
        .map((item) => AnnouncementModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
