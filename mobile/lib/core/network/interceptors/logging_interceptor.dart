import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../config/env/app_env.dart';

/// Wrapper tipis di atas [PrettyDioLogger] agar logging bisa dimatikan
/// lewat `.env` (ENABLE_LOGGING) tanpa mengubah kode, mis. saat build
/// production.
class LoggingInterceptor {
  const LoggingInterceptor._();

  static Interceptor? build() {
    if (!AppEnv.enableLogging) return null;

    return PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
    );
  }
}
