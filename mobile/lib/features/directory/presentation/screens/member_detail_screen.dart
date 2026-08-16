import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/status_badge.dart';
import '../providers/member_provider.dart';

class MemberDetailScreen extends ConsumerWidget {
  final int id;

  const MemberDetailScreen({
    super.key,
    required this.id,
  });

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberAsync = ref.watch(memberDetailProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: memberAsync.maybeWhen(
          data: (member) => Text(member.fullName),
          orElse: () => const Text('Detail Jemaat'),
        ),
      ),
      body: memberAsync.when(
        data: (member) {
          final initial = member.fullName.isNotEmpty
              ? member.fullName[0].toUpperCase()
              : '?';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ResponsiveLayout(
              maxWidth: AppBreakpoints.detailMaxWidth,
              phone: Column(
                children: [
                  // Header Profile Card
                  AppCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.15),
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    member.fullName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (member.membershipNumber != null)
                                    StatusBadge(
                                      label:
                                          'No. Anggota: ${member.membershipNumber}',
                                      type: StatusBadgeType.neutral,
                                      isSmall: true,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            if (member.status != null)
                              StatusBadge(
                                label: member.status == 'active'
                                    ? 'Status: Aktif'
                                    : 'Status: ${member.status}',
                                type: member.status == 'active'
                                    ? StatusBadgeType.success
                                    : StatusBadgeType.neutral,
                              ),
                            if (member.hasAppAccount) ...[
                              const SizedBox(width: AppSpacing.sm),
                              const StatusBadge(
                                label: 'Akun Mobile',
                                type: StatusBadgeType.info,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Member Information Detail Card
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informasi Pribadi & Kontak',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 24),
                        _buildInfoTile(
                          context: context,
                          icon: Icons.person_outline,
                          label: 'Jenis Kelamin',
                          value: member.gender ?? '-',
                        ),
                        _buildInfoTile(
                          context: context,
                          icon: Icons.phone_outlined,
                          label: 'No. Telepon',
                          value: member.phone ?? '-',
                        ),
                        _buildInfoTile(
                          context: context,
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: member.email ?? '-',
                        ),
                        _buildInfoTile(
                          context: context,
                          icon: Icons.location_on_outlined,
                          label: 'Alamat',
                          value: member.address ?? '-',
                        ),
                        _buildInfoTile(
                          context: context,
                          icon: Icons.cake_outlined,
                          label: 'Tanggal Lahir',
                          value: _formatDate(member.birthDate),
                        ),
                        _buildInfoTile(
                          context: context,
                          icon: Icons.water_drop_outlined,
                          label: 'Tanggal Baptis',
                          value: _formatDate(member.baptismDate),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const AppLoadingView(message: 'Memuat detail jemaat...'),
        error: (error, stackTrace) => AppErrorView(
          message: 'Gagal memuat detail jemaat: $error',
          onRetry: () => ref.invalidate(memberDetailProvider(id)),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
