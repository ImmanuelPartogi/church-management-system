import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Skala tipografi aplikasi, dibangun di atas [GoogleFonts.inter].
///
/// Ganti [_fontFamily] ke local font (mis. via pubspec `fonts:`) bila
/// ingin bundling font secara offline daripada memuat via Google Fonts.
class AppTypography {
  const AppTypography._();

  static TextTheme get textTheme => TextTheme(
        displayLarge: _style(32, FontWeight.w700, height: 1.2),
        displayMedium: _style(28, FontWeight.w700, height: 1.2),
        headlineLarge: _style(24, FontWeight.w700, height: 1.25),
        headlineMedium: _style(20, FontWeight.w600, height: 1.3),
        headlineSmall: _style(18, FontWeight.w600, height: 1.3),
        titleLarge: _style(16, FontWeight.w600, height: 1.4),
        titleMedium: _style(14, FontWeight.w600, height: 1.4),
        bodyLarge: _style(16, FontWeight.w400, height: 1.5),
        bodyMedium: _style(14, FontWeight.w400, height: 1.5),
        bodySmall: _style(
          12,
          FontWeight.w400,
          height: 1.4,
          color: AppColors.textSecondary,
        ),
        labelLarge: _style(14, FontWeight.w500, height: 1.2),
        labelMedium: _style(12, FontWeight.w500, height: 1.2),
        labelSmall: _style(
          11,
          FontWeight.w500,
          height: 1.2,
          color: AppColors.textSecondary,
        ),
      );

  static TextStyle _style(
    double size,
    FontWeight weight, {
    double? height,
    Color color = AppColors.textPrimary,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
    );
  }
}
