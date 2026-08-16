import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/status_badge.dart';
import '../providers/warta_provider.dart';

class WartaScreen extends ConsumerWidget {
  const WartaScreen({super.key});

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agt',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wartasAsync = ref.watch(wartaListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Warta Gereja'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(wartaListProvider);
        },
        child: ResponsiveLayout(
          maxWidth: AppBreakpoints.maxContentWidth,
          phone: wartasAsync.when(
            data: (wartas) {
              if (wartas.isEmpty) {
                return const AppEmptyView(
                  title: 'Tidak ada warta tersedia',
                  message: 'Warta jemaat mingguan belum diterbitkan.',
                  icon: Icons.article_outlined,
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: wartas.length,
                itemBuilder: (context, index) {
                  final warta = wartas[index];
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AppCard(
                      onTap: () {
                        context.pushNamed(
                          RouteNames.wartaDetail,
                          pathParameters: {'id': warta.id.toString()},
                        );
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: AppRadius.borderSm,
                            ),
                            child: const Icon(
                              Icons.picture_as_pdf_rounded,
                              color: AppColors.error,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  warta.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (warta.description != null &&
                                    warta.description!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    warta.description!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: AppSpacing.sm),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    StatusBadge(
                                      label: _formatDate(warta.publishedAt),
                                      type: StatusBadgeType.neutral,
                                      isSmall: true,
                                    ),
                                    StatusBadge(
                                      label: _formatFileSize(warta.fileSize),
                                      type: StatusBadgeType.info,
                                      isSmall: true,
                                    ),
                                    if (warta.downloadCount > 0)
                                      StatusBadge(
                                        label: 'Unduh: ${warta.downloadCount}',
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
                    ),
                  );
                },
              );
            },
            loading: () => const AppLoadingView(useSkeleton: false),
            error: (error, stack) => AppErrorView(
              message: 'Gagal memuat warta: $error',
              onRetry: () => ref.invalidate(wartaListProvider),
            ),
          ),
        ),
      ),
    );
  }
}
