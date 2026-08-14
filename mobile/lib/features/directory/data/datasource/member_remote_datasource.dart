import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/member_detail_model.dart';
import '../models/member_directory_model.dart';

final memberRemoteDataSourceProvider = Provider<MemberRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return MemberRemoteDataSource(dio);
});

class MemberRemoteDataSource {
  final Dio _dio;

  MemberRemoteDataSource(this._dio);

  Future<List<MemberDirectoryModel>> searchMembers({
    String? query,
    int page = 1,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
    };
    if (query != null && query.trim().isNotEmpty) {
      queryParameters['q'] = query.trim();
    }

    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.memberSearchEndpoint,
      queryParameters: queryParameters,
    );
    final json = response.data as Map<String, dynamic>;
    final list = json['data'] as List<dynamic>;

    return list
        .map(
          (item) => MemberDirectoryModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<MemberDetailModel> getMemberDetail(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.memberDetailEndpoint(id),
    );
    final json = response.data as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>;

    return MemberDetailModel.fromJson(data);
  }
}
