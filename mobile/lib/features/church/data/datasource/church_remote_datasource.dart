import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/church_model.dart';

final churchRemoteDataSourceProvider =
    Provider<ChurchRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return ChurchRemoteDataSource(dio);
});

class ChurchRemoteDataSource {
  final Dio _dio;

  ChurchRemoteDataSource(this._dio);

  Future<List<ChurchModel>> getChurches() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.churchesEndpoint,
    );
    final data = response.data?['data'];
    if (data is List) {
      return data
          .map((item) => ChurchModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
