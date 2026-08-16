import 'package:flutter/material.dart';

/// Spacing scale (multiples of 4px) for rhythmically consistent UI layout.
class AppSpacing {
  const AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  // Insets helpers
  static const EdgeInsets pageMargin =
      EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
}

/// Border radius scale.
class AppRadius {
  const AppRadius._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;

  static final BorderRadius borderXs = BorderRadius.circular(xs);
  static final BorderRadius borderSm = BorderRadius.circular(sm);
  static final BorderRadius borderMd = BorderRadius.circular(md);
  static final BorderRadius borderLg = BorderRadius.circular(lg);
  static final BorderRadius borderXl = BorderRadius.circular(xl);
  static final BorderRadius borderPill = BorderRadius.circular(pill);
}

/// Elevation & Shadow tokens.
class AppShadows {
  const AppShadows._();

  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x0A0F172A),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x140F172A),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
}

/// Responsive Breakpoints (in logical pixels).
class AppBreakpoints {
  const AppBreakpoints._();

  static const double phone = 480;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double maxContentWidth = 1200;
  static const double formMaxWidth = 640;
  static const double detailMaxWidth = 800;
}
