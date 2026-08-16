import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/status_badge.dart';
import '../providers/servant_provider.dart';

class ServantDetailScreen extends ConsumerWidget {
  final int id;

  const ServantDetailScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servantAsync = ref.watch(servantDetailProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: servantAsync.maybeWhen(
          data: (servant) => Text(servant.name),
          orElse: () => const Text('Detail Pelayan'),
        ),
      ),
      body: servantAsync.when(
        data: (servant) {
          final initial =
              servant.name.isNotEmpty ? servant.name[0].toUpperCase() : '?';

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
                        CircleAvatar(
                          radius: 36,
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.15),
                          child: Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          servant.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        StatusBadge(
                          label: servant.roleLabel,
                          type: StatusBadgeType.info,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Servant Information Card
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informasi Pelayanan & Kontak',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 24),
                        _buildInfoTile(
                          context: context,
                          icon: Icons.phone_outlined,
                          label: 'No. Telepon / Kontak',
                          value: servant.phone ?? servant.maskedPhone ?? '-',
                        ),
                        _buildInfoTile(
                          context: context,
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: servant.email ?? '-',
                        ),
                        _buildInfoTile(
                          context: context,
                          icon: Icons.church_outlined,
                          label: 'Resort',
                          value: servant.resortName ?? '-',
                        ),
                        _buildInfoTile(
                          context: context,
                          icon: Icons.location_city_outlined,
                          label: 'Sektor',
                          value: servant.sectorName ?? '-',
                        ),
                        _buildInfoTile(
                          context: context,
                          icon: Icons.groups_outlined,
                          label: 'Punguan / Seksi',
                          value: servant.fellowshipName ?? '-',
                        ),
                        if (servant.description != null &&
                            servant.description!.isNotEmpty)
                          _buildInfoTile(
                            context: context,
                            icon: Icons.notes_outlined,
                            label: 'Keterangan / Tugas',
                            value: servant.description!,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () =>
            const AppLoadingView(message: 'Memuat detail pelayan...'),
        error: (error, stackTrace) => AppErrorView(
          message: 'Gagal memuat detail pelayan: $error',
          onRetry: () => ref.invalidate(servantDetailProvider(id)),
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
