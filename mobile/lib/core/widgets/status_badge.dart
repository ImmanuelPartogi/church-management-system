import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

enum StatusBadgeType { success, warning, error, info, neutral, primary }

/// Polished status badge widget with cohesive semantic color palette.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.label,
    super.key,
    this.type = StatusBadgeType.info,
    this.icon,
    this.isSmall = false,
  });

  final String label;
  final StatusBadgeType type;
  final IconData? icon;
  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor) = switch (type) {
      StatusBadgeType.success => (AppColors.successBg, AppColors.success),
      StatusBadgeType.warning => (AppColors.warningBg, AppColors.warning),
      StatusBadgeType.error => (AppColors.errorBg, AppColors.error),
      StatusBadgeType.info => (AppColors.infoBg, AppColors.info),
      StatusBadgeType.primary => (
          AppColors.primary.withValues(alpha: 0.1),
          AppColors.primary
        ),
      StatusBadgeType.neutral => (
          const Color(0xFFF1F5F9),
          const Color(0xFF475569)
        ),
    };

    final double fontSize = isSmall ? 10.0 : 11.0;
    final EdgeInsets padding = isSmall
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 2)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 4);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.borderPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
