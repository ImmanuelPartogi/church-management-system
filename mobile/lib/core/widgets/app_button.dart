import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

enum AppButtonVariant { primary, outlined, text, danger }

enum AppButtonSize { small, medium, large }

/// Standard production button with built-in loading state, icon support,
/// and consistent 48px minimum tap target height.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;

    final double height = switch (size) {
      AppButtonSize.small => 36.0,
      AppButtonSize.medium => 48.0,
      AppButtonSize.large => 56.0,
    };

    final double iconSize = size == AppButtonSize.small ? 16.0 : 20.0;

    final child = isLoading
        ? SizedBox(
            height: iconSize,
            width: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == AppButtonVariant.primary ||
                        variant == AppButtonVariant.danger
                    ? Colors.white
                    : AppColors.primary,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: iconSize),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    Widget button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(fullWidth ? double.infinity : 88, height),
          ),
          child: child,
        ),
      AppButtonVariant.outlined => OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: Size(fullWidth ? double.infinity : 88, height),
          ),
          child: child,
        ),
      AppButtonVariant.text => TextButton(
          onPressed: effectiveOnPressed,
          style: TextButton.styleFrom(
            minimumSize: Size(fullWidth ? double.infinity : 88, height),
          ),
          child: child,
        ),
      AppButtonVariant.danger => ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            minimumSize: Size(fullWidth ? double.infinity : 88, height),
          ),
          child: child,
        ),
    };

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
