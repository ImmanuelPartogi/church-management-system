import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/financial_report_model.dart';

final financeRemoteDataSourceProvider =
    Provider<FinanceRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return FinanceRemoteDataSource(dio);
});

class FinanceRemoteDataSource {
  final Dio _dio;

  FinanceRemoteDataSource(this._dio);

  Future<FinancialReportModel> getFinancialReport({
    String? from,
    String? to,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (from != null && from.isNotEmpty) {
      queryParameters['from'] = from;
    }
    if (to != null && to.isNotEmpty) {
      queryParameters['to'] = to;
    }

    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.financialTransparencyEndpoint,
      queryParameters: queryParameters,
    );
    final json = response.data as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>;

    return FinancialReportModel.fromJson(data);
  }
}
