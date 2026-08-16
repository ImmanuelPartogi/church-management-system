import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../providers/announcement_provider.dart';

class AnnouncementScreen extends ConsumerWidget {
  const AnnouncementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(announcementListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengumuman Gereja'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(announcementListProvider);
        },
        child: ResponsiveLayout(
          maxWidth: AppBreakpoints.maxContentWidth,
          phone: announcementsAsync.when(
            data: (announcements) {
              if (announcements.isEmpty) {
                return const AppEmptyView(
                  title: 'Belum Ada Pengumuman',
                  message: 'Pengumuman gereja terbaru belum tersedia saat ini.',
                  icon: Icons.campaign_outlined,
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: announcements.length,
                itemBuilder: (context, index) {
                  final announcement = announcements[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.accent.withValues(alpha: 0.15),
                                  borderRadius: AppRadius.borderSm,
                                ),
                                child: const Icon(
                                  Icons.campaign_rounded,
                                  color: AppColors.accent,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  announcement.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (announcement.publishedAt != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              announcement.publishedAt!,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            announcement.content,
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
                  );
                },
              );
            },
            loading: () =>
                const AppSkeletonListView(itemCount: 4, cardHeight: 100),
            error: (error, stack) => AppErrorView(
              message: 'Gagal memuat pengumuman: $error',
              onRetry: () => ref.invalidate(announcementListProvider),
            ),
          ),
        ),
      ),
    );
  }
}
