import 'package:dio/dio.dart';
import 'package:church_management_mobile/core/constants/api_constants.dart';
import 'package:church_management_mobile/core/error/exceptions.dart';
import 'package:church_management_mobile/features/search/data/models/global_search_result_model.dart';

abstract class SearchRemoteDataSource {
  Future<GlobalSearchResultModel> search(String query);
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final Dio dio;

  SearchRemoteDataSourceImpl(this.dio);

  @override
  Future<GlobalSearchResultModel> search(String query) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        ApiConstants.searchEndpoint,
        queryParameters: {'q': query.trim()},
      );

      if (response.data != null) {
        return GlobalSearchResultModel.fromJson(response.data!);
      } else {
        throw const ServerException('Invalid response from search API');
      }
    } on DioException catch (e) {
      throw ServerException(
        (e.response?.data['message'] as String?) ?? 'Search failed to complete',
      );
    }
  }
}
