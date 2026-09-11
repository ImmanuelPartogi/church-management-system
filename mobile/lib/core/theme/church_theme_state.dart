import 'package:flutter/material.dart';

/// Immutable state representing church tenant visual branding.
class ChurchThemeState {
  final Color primaryColor;
  final Color secondaryColor;
  final int themeVersion;
  final String? logoUrl;
  final bool isCustom;

  /// Tier 3 Hardcoded Platform Defaults
  static const Color defaultPrimary = Color(0xFF1B4B66); // Platform Primary Navy
  static const Color defaultSecondary = Color(0xFFF5A623); // Platform Secondary Amber
  static const int defaultVersion = 1;

  const ChurchThemeState({
    this.primaryColor = defaultPrimary,
    this.secondaryColor = defaultSecondary,
    this.themeVersion = defaultVersion,
    this.logoUrl,
    this.isCustom = false,
  });

  ChurchThemeState copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    int? themeVersion,
    String? logoUrl,
    bool? isCustom,
  }) {
    return ChurchThemeState(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      themeVersion: themeVersion ?? this.themeVersion,
      logoUrl: logoUrl ?? this.logoUrl,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  /// Robust hex color parser supporting '#RRGGBB', 'RRGGBB', and '#AARRGGBB'
  static Color parseHexColor(String? hexString, Color fallback) {
    if (hexString == null || hexString.trim().isEmpty) {
      return fallback;
    }

    String clean = hexString.replaceAll('#', '').trim();
    if (clean.length == 6) {
      clean = 'FF$clean';
    } else if (clean.length != 8) {
      return fallback;
    }

    try {
      final value = int.parse(clean, radix: 16);
      return Color(value);
    } catch (_) {
      return fallback;
    }
  }

  /// Converts a Color to standard 7-char Hex string '#RRGGBB'
  static String toHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  Map<String, dynamic> toJson() {
    return {
      'theme_primary_color': toHex(primaryColor),
      'theme_secondary_color': toHex(secondaryColor),
      'theme_version': themeVersion,
      'logo_url': logoUrl,
    };
  }

  factory ChurchThemeState.fromJson(Map<String, dynamic> json) {
    return ChurchThemeState(
      primaryColor: parseHexColor(json['theme_primary_color']?.toString(), defaultPrimary),
      secondaryColor: parseHexColor(json['theme_secondary_color']?.toString(), defaultSecondary),
      themeVersion: json['theme_version'] is int
          ? json['theme_version'] as int
          : int.tryParse(json['theme_version']?.toString() ?? '1') ?? 1,
      logoUrl: json['logo_url']?.toString(),
      isCustom: true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChurchThemeState &&
          runtimeType == other.runtimeType &&
          primaryColor.toARGB32() == other.primaryColor.toARGB32() &&
          secondaryColor.toARGB32() == other.secondaryColor.toARGB32() &&
          themeVersion == other.themeVersion &&
          logoUrl == other.logoUrl;

  @override
  int get hashCode =>
      primaryColor.toARGB32().hashCode ^
      secondaryColor.toARGB32().hashCode ^
      themeVersion.hashCode ^
      logoUrl.hashCode;

  @override
  String toString() =>
      'ChurchThemeState(primary: ${toHex(primaryColor)}, secondary: ${toHex(secondaryColor)}, v$themeVersion, custom: $isCustom)';
}
