import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/tenant_interceptor.dart';

final dioClientProvider = Provider<Dio>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);

  final connectTimeoutMs = dotenv.isInitialized
      ? (int.tryParse(dotenv.env['API_CONNECT_TIMEOUT'] ?? '') ?? 15000)
      : 15000;
  final receiveTimeoutMs = dotenv.isInitialized
      ? (int.tryParse(dotenv.env['API_RECEIVE_TIMEOUT'] ?? '') ?? 15000)
      : 15000;
  final enableLogging =
      dotenv.isInitialized && dotenv.env['ENABLE_LOGGING'] == 'true';

  final options = BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: Duration(milliseconds: connectTimeoutMs),
    receiveTimeout: Duration(milliseconds: receiveTimeoutMs),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  );

  final dio = Dio(options);

  dio.interceptors.add(
    AuthInterceptor(
      secureStorage,
      onUnauthorized: () {
        ref.read(authNotifierProvider.notifier).forceLogout();
      },
    ),
  );

  dio.interceptors.add(
    TenantInterceptor(ref, dio),
  );

  if (enableLogging) {
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        compact: true,
      ),
    );
  }

  return dio;
});
