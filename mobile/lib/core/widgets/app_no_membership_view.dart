import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import 'app_button.dart';

/// AppNoMembershipView displays an informative and polite state when an
/// authenticated user does not have any active church membership.
class AppNoMembershipView extends StatelessWidget {
  const AppNoMembershipView({
    super.key,
    this.title = 'Belum Terhubung ke Gereja',
    this.message =
        'Akun Anda belum memiliki keanggotaan aktif di gereja mana pun. Silakan hubungi pengurus atau sekretariat gereja untuk mengaktifkan status jemaat Anda.',
    this.onLogout,
  });

  final String title;
  final String message;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceVariantDark
                    : const Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_off_outlined,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            if (onLogout != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Keluar Akun',
                icon: Icons.logout_rounded,
                variant: AppButtonVariant.outlined,
                onPressed: onLogout,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
