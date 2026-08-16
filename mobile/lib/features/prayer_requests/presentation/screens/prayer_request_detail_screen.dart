import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/status_badge.dart';
import '../providers/prayer_request_provider.dart';

class PrayerRequestDetailScreen extends ConsumerWidget {
  final int id;

  const PrayerRequestDetailScreen({
    super.key,
    required this.id,
  });

  StatusBadgeType _getStatusBadgeType(String status) {
    final lower = status.toLowerCase();
    if (lower == 'submitted') return StatusBadgeType.warning;
    if (lower == 'prayed') return StatusBadgeType.info;
    if (lower == 'followed_up') return StatusBadgeType.success;
    return StatusBadgeType.neutral;
  }

  String _getStatusLabel(String status) {
    final lower = status.toLowerCase();
    if (lower == 'submitted') return 'Menunggu Didoakan';
    if (lower == 'prayed') return 'Sudah Didoakan';
    if (lower == 'followed_up') return 'Sudah Ditindaklanjuti';
    return status;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final dateTime = DateTime.parse(dateStr);
      return DateFormat('d MMMM yyyy HH:mm', 'id_ID').format(dateTime);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(prayerRequestDetailProvider(id));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Permohonan Doa'),
      ),
      body: detailAsync.when(
        data: (item) {
          final hasFollowUp = item.followUpNotes != null &&
              item.followUpNotes!.trim().isNotEmpty;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ResponsiveLayout(
              maxWidth: AppBreakpoints.detailMaxWidth,
              phone: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            StatusBadge(
                              label: item.isPrivate ? 'Privat' : 'Publik',
                              type: item.isPrivate
                                  ? StatusBadgeType.neutral
                                  : StatusBadgeType.info,
                            ),
                            StatusBadge(
                              label: _getStatusLabel(item.status),
                              type: _getStatusBadgeType(item.status),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (item.category != null &&
                            item.category!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Kategori: ${item.category}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Dikirim: ${_formatDate(item.createdAt)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Content Card
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Isi Permohonan Doa',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        const Divider(),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          item.content,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Pastoral Care Follow-up Card
                  if (hasFollowUp ||
                      item.status.toLowerCase() == 'followed_up' ||
                      item.status.toLowerCase() == 'prayed') ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: AppRadius.borderMd,
                        border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.success,
                                child: Icon(
                                  Icons.volunteer_activism_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Tanggapan / Tindak Lanjut Pastoral',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Divider(color: AppColors.success),
                          const SizedBox(height: 8),
                          Text(
                            hasFollowUp
                                ? item.followUpNotes!
                                : 'Permohonan doa Anda telah didoakan oleh Tim Pastoral Gereja.',
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          if (item.followedUpAt != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 14,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Ditindaklanjuti pada: ${_formatDate(item.followedUpAt)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.success,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
        loading: () =>
            const AppLoadingView(message: 'Memuat detail permohonan doa...'),
        error: (error, stack) => AppErrorView(
          message: 'Gagal memuat detail permohonan doa: $error',
          onRetry: () => ref.invalidate(prayerRequestDetailProvider(id)),
        ),
      ),
    );
  }
}
