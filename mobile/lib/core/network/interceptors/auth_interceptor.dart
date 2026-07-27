import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../constants/storage_keys.dart';

/// Menyisipkan Sanctum token Laravel ke setiap request, dan menandai
/// response 401 supaya bisa ditangani (mis. redirect ke login) oleh
/// layer di atasnya.
///
/// Logika refresh token / logout-on-401 akan diimplementasikan pada fase
/// pengembangan modul Authentication.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._secureStorage);

  final FlutterSecureStorage _secureStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.read(key: StorageKeys.sanctumToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Accept'] = 'application/json';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // TODO(auth): pada fase Authentication, tangani 401 di sini
    // (mis. clear token & trigger navigasi ke halaman login via router).
    handler.next(err);
  }
}
