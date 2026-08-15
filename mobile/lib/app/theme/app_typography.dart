import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Complete typography scale for the Church Management System.
class AppTypography {
  const AppTypography._();

  static TextTheme textTheme(bool isDark) {
    final primaryColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return TextTheme(
      displayLarge: _inter(32, FontWeight.w700, height: 1.2, color: primaryColor),
      displayMedium: _inter(28, FontWeight.w700, height: 1.2, color: primaryColor),
      displaySmall: _inter(24, FontWeight.w700, height: 1.2, color: primaryColor),

      headlineLarge: _inter(22, FontWeight.w700, height: 1.25, color: primaryColor),
      headlineMedium: _inter(20, FontWeight.w600, height: 1.3, color: primaryColor),
      headlineSmall: _inter(18, FontWeight.w600, height: 1.3, color: primaryColor),

      titleLarge: _inter(16, FontWeight.w600, height: 1.4, color: primaryColor),
      titleMedium: _inter(14, FontWeight.w600, height: 1.4, color: primaryColor),
      titleSmall: _inter(13, FontWeight.w600, height: 1.4, color: primaryColor),

      bodyLarge: _inter(16, FontWeight.w400, height: 1.5, color: primaryColor),
      bodyMedium: _inter(14, FontWeight.w400, height: 1.5, color: primaryColor),
      bodySmall: _inter(12, FontWeight.w400, height: 1.4, color: secondaryColor),

      labelLarge: _inter(14, FontWeight.w600, height: 1.2, color: primaryColor),
      labelMedium: _inter(12, FontWeight.w500, height: 1.2, color: secondaryColor),
      labelSmall: _inter(11, FontWeight.w500, height: 1.2, color: secondaryColor),
    );
  }

  /// Elegant serif style for Daily Verse & Scripture content.
  static TextStyle scriptureStyle({
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double height = 1.6,
  }) {
    return GoogleFonts.newsreader(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: FontStyle.italic,
      height: height,
      color: color ?? AppColors.textPrimaryLight,
    );
  }

  static TextStyle _inter(
    double size,
    FontWeight weight, {
    double? height,
    required Color color,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
    );
  }
}
