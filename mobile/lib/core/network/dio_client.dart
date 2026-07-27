import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/env/app_env.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

/// Satu-satunya factory [Dio] untuk seluruh aplikasi. Semua remote
/// datasource wajib menggunakan instance ini (di-inject lewat
/// [lib/core/di/injection.dart]) alih-alih membuat `Dio()` sendiri-sendiri,
/// supaya base URL, timeout, dan interceptor tetap konsisten.
class DioClient {
  const DioClient._();

  static Dio create({required FlutterSecureStorage secureStorage}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppEnv.apiBaseUrl,
        connectTimeout: AppEnv.connectTimeout,
        receiveTimeout: AppEnv.receiveTimeout,
        contentType: 'application/json',
      ),
    );

    dio.interceptors.add(AuthInterceptor(secureStorage));

    final loggingInterceptor = LoggingInterceptor.build();
    if (loggingInterceptor != null) {
      dio.interceptors.add(loggingInterceptor);
    }

    return dio;
  }
}
