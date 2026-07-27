import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/di/core_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Muat konfigurasi environment (lihat .env.example).
  await dotenv.load(fileName: '.env');

  // Firebase.initializeApp() akan ditambahkan di fase implementasi
  // modul Authentication & Notifikasi (butuh google-services.json /
  // GoogleService-Info.plist per platform terlebih dahulu).
  // await Firebase.initializeApp();

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const App(),
    ),
  );
}
