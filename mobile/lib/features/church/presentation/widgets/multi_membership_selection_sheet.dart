import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/church.dart';
import '../providers/tenant_provider.dart';

/// Shows the modal bottom sheet allowing users with >= 2 memberships
/// to choose their active church tenant.
void showMultiMembershipSelectionSheet(
  BuildContext context,
  WidgetRef ref,
  User user,
) {
  showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Gereja Aktif',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Akun Anda terdaftar di lebih dari satu gereja. Silakan pilih gereja yang ingin Anda akses saat ini:',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ...user.memberships.map((m) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(
                      Icons.church_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    m.churchName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Peran: ${m.role}'),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await ref.read(tenantProvider.notifier).selectChurch(
                          Church(
                            id: m.churchId,
                            uuid: m.churchUuid ?? '',
                            name: m.churchName,
                            slug: m.churchSlug,
                          ),
                        );
                  },
                );
              }),
            ],
          ),
        ),
      );
    },
  ).whenComplete(() {
    ref.read(tenantProvider.notifier).dismissMultiMembershipPrompt();
  });
}
