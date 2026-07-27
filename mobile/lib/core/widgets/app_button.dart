import 'package:flutter/material.dart';

/// Tombol standar aplikasi dengan built-in loading state, supaya setiap
/// screen tidak perlu mengelola `CircularProgressIndicator` overlay sendiri.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    final effectiveOnPressed = isLoading ? null : onPressed;

    return variant == AppButtonVariant.primary
        ? ElevatedButton(onPressed: effectiveOnPressed, child: child)
        : OutlinedButton(onPressed: effectiveOnPressed, child: child);
  }
}

enum AppButtonVariant { primary, outlined }
