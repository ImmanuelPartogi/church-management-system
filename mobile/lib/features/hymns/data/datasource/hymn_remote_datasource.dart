import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/song_model.dart';
import '../models/songbook_model.dart';

final hymnRemoteDataSourceProvider = Provider<HymnRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return HymnRemoteDataSource(dio);
});

class HymnRemoteDataSource {
  final Dio _dio;

  HymnRemoteDataSource(this._dio);

  Future<List<SongbookModel>> getSongbooks() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.songbooksEndpoint,
    );
    final json = response.data as Map<String, dynamic>;
    final list = json['data'] as List<dynamic>;

    return list
        .map((item) => SongbookModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<SongModel>> getSongs({
    String? search,
    int? songbookId,
    int page = 1,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
    };

    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }

    if (songbookId != null) {
      queryParameters['songbook_id'] = songbookId;
    }

    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.songsEndpoint,
      queryParameters: queryParameters,
    );
    final json = response.data as Map<String, dynamic>;
    final list = json['data'] as List<dynamic>;

    return list
        .map((item) => SongModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<SongModel> getSongDetail(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.songDetailEndpoint(id),
    );
    final json = response.data as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>;

    return SongModel.fromJson(data);
  }
}
