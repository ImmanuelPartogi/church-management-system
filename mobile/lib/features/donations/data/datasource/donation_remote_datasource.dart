import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/church_bank_account_model.dart';
import '../models/donation_confirmation_model.dart';

final donationRemoteDataSourceProvider =
    Provider<DonationRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return DonationRemoteDataSource(dio);
});

class DonationRemoteDataSource {
  final Dio _dio;

  DonationRemoteDataSource(this._dio);

  Future<List<ChurchBankAccountModel>> getChurchBankAccounts() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.churchBankAccountsEndpoint,
    );
    final json = response.data as Map<String, dynamic>;
    final list = json['data'] as List<dynamic>;

    return list
        .map(
          (item) =>
              ChurchBankAccountModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<DonationConfirmationModel>> getMyDonations({
    int page = 1,
    String? startDate,
    String? endDate,
    String? status,
    int? chartOfAccountId,
  }) async {
    final queryParams = <String, dynamic>{'page': page};
    if (startDate != null && startDate.isNotEmpty) {
      queryParams['start_date'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) {
      queryParams['end_date'] = endDate;
    }
    if (status != null && status.isNotEmpty && status != 'all') {
      queryParams['status'] = status;
    }
    if (chartOfAccountId != null) {
      queryParams['chart_of_account_id'] = chartOfAccountId;
    }

    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.myDonationsEndpoint,
      queryParameters: queryParams,
    );
    final json = response.data as Map<String, dynamic>;
    final list = json['data'] as List<dynamic>;

    return list
        .map(
          (item) =>
              DonationConfirmationModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<int>> exportDonations({
    required String format,
    String? startDate,
    String? endDate,
    int? chartOfAccountId,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{'format': format};
    if (startDate != null && startDate.isNotEmpty) {
      queryParams['start_date'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) {
      queryParams['end_date'] = endDate;
    }
    if (chartOfAccountId != null) {
      queryParams['chart_of_account_id'] = chartOfAccountId;
    }
    if (status != null && status.isNotEmpty && status != 'all') {
      queryParams['status'] = status;
    }

    final response = await _dio.get<List<int>>(
      ApiConstants.myDonationsExportEndpoint,
      queryParameters: queryParams,
      options: Options(responseType: ResponseType.bytes),
    );

    return response.data ?? <int>[];
  }

  Future<DonationConfirmationModel> getDonationDetail(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.donationDetailEndpoint(id),
    );
    final json = response.data as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>;

    return DonationConfirmationModel.fromJson(data);
  }

  Future<DonationConfirmationModel> submitDonationConfirmation({
    required int chartOfAccountId,
    required num amount,
    required String transferDate,
    required String senderBank,
    String? depositorPhone,
    String? notes,
    String? proofFilePath,
    void Function(int count, int total)? onSendProgress,
  }) async {
    final formDataMap = <String, dynamic>{
      'chart_of_account_id': chartOfAccountId,
      'amount': amount,
      'transfer_date': transferDate,
      'sender_bank': senderBank,
    };

    if (depositorPhone != null && depositorPhone.isNotEmpty) {
      formDataMap['depositor_phone'] = depositorPhone;
    }

    if (notes != null && notes.isNotEmpty) {
      formDataMap['notes'] = notes;
    }

    if (proofFilePath != null && proofFilePath.isNotEmpty) {
      formDataMap['proof_file'] = await MultipartFile.fromFile(
        proofFilePath,
        filename: proofFilePath.split('/').last,
      );
    }

    final formData = FormData.fromMap(formDataMap);

    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.donationConfirmEndpoint,
      data: formData,
      onSendProgress: onSendProgress,
    );

    final json = response.data as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>;

    return DonationConfirmationModel.fromJson(data);
  }
}
