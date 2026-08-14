import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/warta_model.dart';

final wartaRemoteDataSourceProvider = Provider<WartaRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return WartaRemoteDataSource(dio);
});

class WartaRemoteDataSource {
  final Dio _dio;

  WartaRemoteDataSource(this._dio);

  Future<List<WartaModel>> getWartas({int page = 1}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.wartasEndpoint,
      queryParameters: {'page': page},
    );
    final json = response.data as Map<String, dynamic>;
    final list = json['data'] as List<dynamic>;

    return list
        .map((item) => WartaModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<WartaModel> getWarta(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.wartaDetailEndpoint(id),
    );
    final json = response.data as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>;

    return WartaModel.fromJson(data);
  }

  Future<Response> downloadWarta(
    int id,
    String savePath, {
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.download(
      ApiConstants.wartaDownloadEndpoint(id),
      savePath,
      onReceiveProgress: onReceiveProgress,
    );
  }
}
