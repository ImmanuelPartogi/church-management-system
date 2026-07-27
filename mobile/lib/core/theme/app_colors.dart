import 'package:flutter/material.dart';

/// Palet warna aplikasi. Sengaja dipisah dari [ThemeData] agar bisa
/// direferensikan langsung di widget custom tanpa bergantung pada context
/// (mis. dekorasi status badge, chart, dsb).
class AppColors {
  const AppColors._();

  // Brand
  static const Color primary = Color(0xFF2E5C4F); // hijau tua gereja
  static const Color primaryLight = Color(0xFF4C7C6D);
  static const Color primaryDark = Color(0xFF1B3B32);
  static const Color secondary = Color(0xFFC9A24B); // aksen emas

  // Surface
  static const Color background = Color(0xFFF7F8F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEDEFEC);
  static const Color divider = Color(0xFFE1E3E0);

  // Text
  static const Color textPrimary = Color(0xFF1A1D1B);
  static const Color textSecondary = Color(0xFF5C635F);
  static const Color textDisabled = Color(0xFFA0A6A2);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Status / approval workflow (Formulir, Donasi)
  static const Color statusPending = Color(0xFFB8860B);
  static const Color statusProcessing = Color(0xFF2F6FED);
  static const Color statusApproved = Color(0xFF2E9E5B);
  static const Color statusRejected = Color(0xFFD64545);

  // Semantic (grafik keuangan / jemaat masuk-keluar)
  static const Color positive = Color(0xFF2E9E5B);
  static const Color negative = Color(0xFFD64545);
  static const Color neutral = Color(0xFF7C8783);

  // Overlays
  static const Color overlay = Color(0x99000000);
  static const Color shimmerBase = Color(0xFFE6E8E6);
  static const Color shimmerHighlight = Color(0xFFF4F5F4);
}
