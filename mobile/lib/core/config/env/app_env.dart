import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Membaca konfigurasi environment dari file `.env` (via flutter_dotenv).
///
/// Pastikan `.env` sudah dimuat lebih dulu di `main.dart` sebelum
/// [AppEnv] digunakan:
/// ```dart
/// await dotenv.load(fileName: '.env');
/// ```
class AppEnv {
  const AppEnv._();

  static String get appEnvironment => dotenv.env['APP_ENV'] ?? 'development';

  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api/v1';

  static Duration get connectTimeout => Duration(
        milliseconds: int.tryParse(
              dotenv.env['API_CONNECT_TIMEOUT'] ?? '',
            ) ??
            15000,
      );

  static Duration get receiveTimeout => Duration(
        milliseconds: int.tryParse(
              dotenv.env['API_RECEIVE_TIMEOUT'] ?? '',
            ) ??
            15000,
      );

  static bool get enableLogging =>
      (dotenv.env['ENABLE_LOGGING'] ?? 'true').toLowerCase() == 'true';

  static bool get isProduction => appEnvironment == 'production';

  static bool get isDevelopment => appEnvironment == 'development';
}
