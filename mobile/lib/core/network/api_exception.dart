import 'package:dio/dio.dart';

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final dynamic errors;
  final String? errorCode;
  final String? module;

  const ApiException({
    required this.message,
    this.statusCode,
    this.errors,
    this.errorCode,
    this.module,
  });

  bool get isModuleDisabled => errorCode == 'MODULE_DISABLED';
  bool get isTenantMismatch => errorCode == 'TENANT_MEMBERSHIP_MISMATCH';
  bool get isNoActiveMembership => errorCode == 'NO_ACTIVE_MEMBERSHIP';

  factory ApiException.fromDioException(DioException dioException) =>
      ApiException.fromDioError(dioException);

  factory ApiException.fromDioError(DioException dioError) {
    int? statusCode = dioError.response?.statusCode;
    String message = 'Terjadi kesalahan pada server';
    dynamic errors;
    String? errorCode;
    String? module;

    if (dioError.response?.data != null && dioError.response?.data is Map) {
      final data = dioError.response!.data as Map<String, dynamic>;
      message = data['message']?.toString() ?? message;
      errors = data['errors'];
      errorCode = data['code']?.toString();
      module = data['module']?.toString();
    } else {
      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
          message = 'Koneksi ke server timeout';
          break;
        case DioExceptionType.sendTimeout:
          message = 'Pengiriman data timeout';
          break;
        case DioExceptionType.receiveTimeout:
          message = 'Penerimaan data timeout';
          break;
        case DioExceptionType.badResponse:
          message = 'Bad response dari server';
          break;
        case DioExceptionType.cancel:
          message = 'Permintaan dibatalkan';
          break;
        default:
          message = 'Koneksi internet bermasalah atau server mati';
      }
    }

    return ApiException(
      statusCode: statusCode,
      message: message,
      errors: errors,
      errorCode: errorCode,
      module: module,
    );
  }

  @override
  String toString() => message;
}
