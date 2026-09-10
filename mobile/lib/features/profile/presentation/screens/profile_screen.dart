import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../church/presentation/providers/tenant_provider.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final updateState = ref.watch(profileUpdateNotifierProvider);
    final activeChurch = ref.watch(activeChurchProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
      ),
      body: profileAsync.when(
        data: (profile) => RefreshIndicator(
          onRefresh: () async => ref.refresh(userProfileProvider.future),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ResponsiveLayout(
              maxWidth: AppBreakpoints.detailMaxWidth,
              phone: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. User Header Card
                  _buildUserHeader(context, profile),
                  const SizedBox(height: AppSpacing.md),

                  // Active Church Card
                  _buildSectionCard(
                    context,
                    title: 'Gereja Aktif',
                    icon: Icons.church_rounded,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activeChurch?.name ?? 'Belum memilih gereja',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (activeChurch?.address != null &&
                                  activeChurch!.address!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  activeChurch.address!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        AppButton(
                          label: 'Ganti',
                          icon: Icons.swap_horiz_rounded,
                          variant: AppButtonVariant.outlined,
                          onPressed: () => context.push(RoutePaths.churchSelect),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 2. Account Information Section
                  _buildSectionCard(
                    context,
                    title: 'Informasi Akun',
                    icon: Icons.person_outline_rounded,
                    child: Column(
                      children: [
                        _buildInfoRow(context, 'Nama Lengkap', profile.name),
                        const Divider(),
                        _buildInfoRow(context, 'Email', profile.email),
                        const Divider(),
                        _buildInfoRow(
                          context,
                          'No. Telepon',
                          profile.phone ?? '-',
                        ),
                        const Divider(),
                        _buildInfoRow(
                          context,
                          'Alamat',
                          profile.address ?? '-',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 3. Linked Church Member Section (if linked)
                  if (profile.hasLinkedMember) ...[
                    _buildSectionCard(
                      context,
                      title: 'Data Jemaat Terhubung',
                      icon: Icons.badge_outlined,
                      child: Column(
                        children: [
                          _buildInfoRow(
                            context,
                            'No. Anggota',
                            profile.member!.membershipNumber ?? '-',
                          ),
                          const Divider(),
                          _buildInfoRow(
                            context,
                            'Nama Jemaat',
                            profile.member!.fullName,
                          ),
                          const Divider(),
                          _buildInfoRow(
                            context,
                            'Jenis Kelamin',
                            profile.member!.gender ?? '-',
                          ),
                          const Divider(),
                          _buildInfoRow(
                            context,
                            'Status Jemaat',
                            profile.member!.status ?? '-',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // 4. Action Buttons (Edit Profile)
                  AppButton(
                    label: 'Edit Profil',
                    fullWidth: true,
                    icon: Icons.edit_outlined,
                    variant: AppButtonVariant.primary,
                    onPressed: () =>
                        _showEditProfileDialog(context, ref, profile),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 5. Privacy / UU PDP Information Card
                  AppCard(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? AppColors.surfaceDark
                            : AppColors.info.withValues(alpha: 0.08),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.privacy_tip_outlined,
                          color: AppColors.info,
                          size: 24,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Sesuai UU PDP No. 27/2022, Anda memiliki hak penuh atas pengelolaan dan penghapusan data akun pribadi Anda.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 6. Logout & Delete Account Actions
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.1),
                        borderRadius: AppRadius.borderSm,
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: AppColors.gold,
                      ),
                    ),
                    title: const Text(
                      'Keluar / Logout',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onTap: () =>
                        ref.read(authNotifierProvider.notifier).logout(),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: AppRadius.borderSm,
                      ),
                      child: updateState.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(
                              Icons.delete_forever_rounded,
                              color: AppColors.error,
                            ),
                    ),
                    title: const Text(
                      'Hapus Akun Saya',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text(
                      'Penghapusan akun permanen sesuai regulasi data pribadi UU PDP.',
                      style: TextStyle(fontSize: 11),
                    ),
                    onTap: updateState.isLoading
                        ? null
                        : () => _showAccountDeletionDialog(context, ref),
                  ),
                ],
              ),
            ),
          ),
        ),
        loading: () => const AppLoadingView(message: 'Memuat profil...'),
        error: (err, _) => AppErrorView(
          message: 'Gagal memuat profil: $err',
          onRetry: () => ref.invalidate(userProfileProvider),
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, UserProfile profile) {
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary,
            child: Text(
              profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  profile.email,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    StatusBadge(
                      label: profile.roles.isNotEmpty
                          ? profile.roles.first
                          : 'User',
                      type: StatusBadgeType.neutral,
                      isSmall: true,
                    ),
                    if (profile.hasLinkedMember)
                      const StatusBadge(
                        label: 'Jemaat Terverifikasi',
                        type: StatusBadgeType.success,
                        isSmall: true,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.xs),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
  ) {
    final nameController = TextEditingController(text: profile.name);
    final phoneController = TextEditingController(text: profile.phone ?? '');
    final addressController =
        TextEditingController(text: profile.address ?? '');

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Profil'),
        content: SingleChildScrollView(
          child: ResponsiveLayout(
            maxWidth: AppBreakpoints.formMaxWidth,
            phone: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: nameController,
                  label: 'Nama Lengkap',
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  controller: phoneController,
                  label: 'No. Telepon',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  controller: addressController,
                  label: 'Alamat',
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          AppButton(
            label: 'Simpan',
            onPressed: () async {
              final success = await ref
                  .read(profileUpdateNotifierProvider.notifier)
                  .updateProfile(
                    name: nameController.text,
                    phone: phoneController.text,
                    address: addressController.text,
                  );

              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profil berhasil diperbarui'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gagal memperbarui profil'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAccountDeletionDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: AppSpacing.xs),
            Text('Konfirmasi Hapus Akun'),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus akun Anda? Tindakan ini permanen sesuai regulasi perlindungan data pribadi (UU PDP). Token akses dan preferensi akun Anda akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          AppButton(
            label: 'Hapus Akun',
            variant: AppButtonVariant.danger,
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await ref
                  .read(profileUpdateNotifierProvider.notifier)
                  .deleteAccount();

              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Akun Anda telah dihapus.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  ref.read(authNotifierProvider.notifier).forceLogout();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gagal menghapus akun.'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
