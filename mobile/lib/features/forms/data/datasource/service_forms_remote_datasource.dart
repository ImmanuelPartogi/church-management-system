import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/selected_document.dart';
import '../models/service_form_application_model.dart';
import '../models/service_form_type_model.dart';

final serviceFormsRemoteDataSourceProvider =
    Provider<ServiceFormsRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return ServiceFormsRemoteDataSource(dio);
});

class ServiceFormsRemoteDataSource {
  final Dio _dio;

  ServiceFormsRemoteDataSource(this._dio);

  Future<List<ServiceFormTypeModel>> getServiceFormTypes() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.serviceFormTypesEndpoint,
    );
    final json = response.data as Map<String, dynamic>;
    final list = json['data'] as List<dynamic>;

    return list
        .map(
          (item) => ServiceFormTypeModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<ServiceFormTypeModel> getServiceFormType(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.serviceFormTypeDetailEndpoint(id),
    );
    final json = response.data as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>;

    return ServiceFormTypeModel.fromJson(data);
  }

  Future<List<ServiceFormApplicationModel>> getApplications({
    int page = 1,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.serviceFormApplicationsEndpoint,
      queryParameters: {'page': page},
    );
    final json = response.data as Map<String, dynamic>;
    final list = json['data'] as List<dynamic>;

    return list
        .map(
          (item) => ServiceFormApplicationModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<ServiceFormApplicationModel> getApplication(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.serviceFormApplicationDetailEndpoint(id),
    );
    final json = response.data as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>;

    return ServiceFormApplicationModel.fromJson(data);
  }

  Future<ServiceFormApplicationModel> submitApplication({
    required int serviceFormTypeId,
    String? applicantNotes,
    required List<SelectedDocument> documents,
  }) async {
    final formDataMap = <String, dynamic>{
      'service_form_type_id': serviceFormTypeId,
    };

    if (applicantNotes != null && applicantNotes.isNotEmpty) {
      formDataMap['applicant_notes'] = applicantNotes;
    }

    for (var i = 0; i < documents.length; i++) {
      final doc = documents[i];
      formDataMap['documents[$i][document_name]'] = doc.documentName;
      formDataMap['documents[$i][file]'] = await MultipartFile.fromFile(
        doc.filePath,
        filename: doc.fileName,
      );
    }

    final formData = FormData.fromMap(formDataMap);

    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.serviceFormApplicationsEndpoint,
      data: formData,
    );

    final json = response.data as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>;

    return ServiceFormApplicationModel.fromJson(data);
  }
}
