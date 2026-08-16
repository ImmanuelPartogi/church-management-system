import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/status_badge.dart';
import '../providers/prayer_request_provider.dart';

class PrayerRequestsScreen extends ConsumerWidget {
  const PrayerRequestsScreen({super.key});

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

  String _formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr);
      return DateFormat('d MMMM yyyy', 'id_ID').format(dateTime);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(prayerRequestListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Permohonan Doa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Buat Permohonan Doa',
            onPressed: () {
              context.push(RoutePaths.createPrayerRequest);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(RoutePaths.createPrayerRequest);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.edit_rounded, color: Colors.white),
        label: const Text(
          'Buat Pokok Doa',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(prayerRequestListProvider);
        },
        child: ResponsiveLayout(
          maxWidth: AppBreakpoints.maxContentWidth,
          phone: listAsync.when(
            data: (requests) {
              if (requests.isEmpty) {
                return AppEmptyView(
                  title: 'Belum Ada Permohonan Doa',
                  message:
                      'Sampaikan permohonan doa Anda agar dapat didoakan oleh Tim Pastoral Gereja.',
                  icon: Icons.volunteer_activism_outlined,
                  actionLabel: 'Ajukan Pokok Doa Baru',
                  onAction: () => context.push(RoutePaths.createPrayerRequest),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final item = requests[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AppCard(
                      onTap: () {
                        context.pushNamed(
                          RouteNames.prayerRequestDetail,
                          pathParameters: {'id': item.id.toString()},
                        );
                      },
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
                                isSmall: true,
                              ),
                              StatusBadge(
                                label: _getStatusLabel(item.status),
                                type: _getStatusBadgeType(item.status),
                                isSmall: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (item.category != null &&
                              item.category!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Kategori: ${item.category}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Text(
                            item.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDate(item.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.textMutedDark
                                      : AppColors.textMutedLight,
                                ),
                              ),
                              if (item.followUpNotes != null &&
                                  item.followUpNotes!.isNotEmpty)
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.comment_rounded,
                                      size: 14,
                                      color: AppColors.primary,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Ada Tanggapan',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () =>
                const AppSkeletonListView(itemCount: 4, cardHeight: 110),
            error: (error, stack) => AppErrorView(
              message: 'Gagal memuat permohonan doa: $error',
              onRetry: () => ref.invalidate(prayerRequestListProvider),
            ),
          ),
        ),
      ),
    );
  }
}
