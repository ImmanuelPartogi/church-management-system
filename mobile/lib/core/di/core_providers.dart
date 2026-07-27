import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';

/// Provider-provider infrastruktur tingkat aplikasi (bukan spesifik satu
/// feature). Feature-level provider (repository, usecase, dst) berada di
/// masing-masing `lib/features/<feature>/presentation/providers/`.

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final dioProvider = Provider<Dio>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return DioClient.create(secureStorage: secureStorage);
});

/// Diisi (override) di `main.dart` dengan instance yang sudah di-`await`,
/// karena `SharedPreferences.getInstance()` bersifat async sementara
/// provider ini perlu diakses secara sync di banyak tempat.
///
/// ```dart
/// final sharedPrefs = await SharedPreferences.getInstance();
/// runApp(
///   ProviderScope(
///     overrides: [
///       sharedPreferencesProvider.overrideWithValue(sharedPrefs),
///     ],
///     child: const App(),
///   ),
/// );
/// ```
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider harus di-override di main.dart '
    'setelah SharedPreferences.getInstance() selesai.',
  );
});
