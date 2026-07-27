import 'package:dio/dio.dart';

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final dynamic errors;

  const ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  factory ApiException.fromDioError(DioException dioError) {
    int? statusCode = dioError.response?.statusCode;
    String message = 'Terjadi kesalahan pada server';
    dynamic errors;

    if (dioError.response?.data != null && dioError.response?.data is Map) {
      final data = dioError.response!.data as Map<String, dynamic>;
      message = data['message']?.toString() ?? message;
      errors = data['errors'];
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
    );
  }

  @override
  String toString() => message;
}
