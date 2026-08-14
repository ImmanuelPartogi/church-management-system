import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/sermon_model.dart';

final sermonRemoteDataSourceProvider = Provider<SermonRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return SermonRemoteDataSource(dio);
});

class SermonRemoteDataSource {
  final Dio _dio;

  SermonRemoteDataSource(this._dio);

  Future<List<SermonModel>> getSermons({
    String? search,
    int page = 1,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
    };
    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }

    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.sermonsEndpoint,
      queryParameters: queryParameters,
    );
    final json = response.data as Map<String, dynamic>;
    final list = json['data'] as List<dynamic>;

    return list
        .map((item) => SermonModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<SermonModel> getSermonDetail(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.sermonDetailEndpoint(id),
    );
    final json = response.data as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>;

    return SermonModel.fromJson(data);
  }

  Future<int> downloadSermon(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.sermonDownloadEndpoint(id),
    );
    final json = response.data as Map<String, dynamic>;
    if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
      final data = json['data'] as Map<String, dynamic>;
      return (data['download_count'] as int?) ?? 1;
    }
    return 1;
  }
}
