import 'package:flutter/material.dart';
import '../../app/theme/app_spacing.dart';

/// ResponsiveLayout wrapper for rendering Phone (<600px), Tablet (600px–1024px),
/// and Desktop (>1024px) layouts while constraining content max width.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.phone,
    super.key,
    this.tablet,
    this.desktop,
    this.maxWidth = AppBreakpoints.maxContentWidth,
  });

  final Widget phone;
  final Widget? tablet;
  final Widget? desktop;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        Widget content;
        if (width >= AppBreakpoints.desktop && desktop != null) {
          content = desktop!;
        } else if (width >= AppBreakpoints.tablet && tablet != null) {
          content = tablet!;
        } else {
          content = phone;
        }

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: content,
          ),
        );
      },
    );
  }
}
