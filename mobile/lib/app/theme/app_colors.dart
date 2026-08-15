import 'package:flutter/material.dart';

/// Systematic semantic color tokens for Light and Dark modes.
class AppColors {
  const AppColors._();

  // Brand Core
  static const Color primary = Color(0xFF0F172A); // Deep Slate / Midnight
  static const Color primaryLight = Color(0xFF1E293B);
  static const Color primaryAccent = Color(0xFF2563EB); // Royal Blue

  // Accent & Highlights
  static const Color gold = Color(0xFFD97706); // Warm Amber/Gold
  static const Color goldLight = Color(0xFFFBBF24);
  static const Color goldBg = Color(0xFFFEF3C7);

  // Status & Feedback
  static const Color success = Color(0xFF059669); // Soft Emerald
  static const Color successBg = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFD97706);
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color error = Color(0xFFDC2626); // Soft Crimson
  static const Color errorBg = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF2563EB);
  static const Color infoBg = Color(0xFFEFF6FF);

  // Neutrals - Light Mode
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceVariantLight = Color(0xFFF1F5F9);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);

  // Neutrals - Dark Mode
  static const Color backgroundDark = Color(0xFF0B0F19);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceVariantDark = Color(0xFF334155);
  static const Color borderDark = Color(0xFF334155);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color textMutedDark = Color(0xFF64748B);
}
