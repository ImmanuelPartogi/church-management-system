import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/church_servant_model.dart';

final servantRemoteDataSourceProvider =
    Provider<ServantRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return ServantRemoteDataSource(dio);
});

class ServantRemoteDataSource {
  final Dio _dio;

  ServantRemoteDataSource(this._dio);

  Future<List<ChurchServantModel>> getServants({
    String? search,
    String? role,
    int? sectorId,
    int page = 1,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
    };
    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }
    if (role != null && role.trim().isNotEmpty) {
      queryParameters['role'] = role.trim();
    }
    if (sectorId != null) {
      queryParameters['sector_id'] = sectorId;
    }

    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.servantsEndpoint,
      queryParameters: queryParameters,
    );
    final json = response.data as Map<String, dynamic>;
    final list = json['data'] as List<dynamic>;

    return list
        .map(
          (item) => ChurchServantModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<ChurchServantModel> getServantDetail(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.servantDetailEndpoint(id),
    );
    final json = response.data as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>;

    return ChurchServantModel.fromJson(data);
  }
}
