import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/status_badge.dart';
import '../providers/hymn_provider.dart';

class HymnDetailScreen extends ConsumerWidget {
  final int id;

  const HymnDetailScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songAsync = ref.watch(songDetailProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: songAsync.maybeWhen(
          data: (song) => Text(
            '${song.songbookCode ?? "Lagu"} No. ${song.number}',
          ),
          orElse: () => const Text('Detail Lagu'),
        ),
      ),
      body: songAsync.when(
        data: (song) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ResponsiveLayout(
              maxWidth: AppBreakpoints.detailMaxWidth,
              phone: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card with Songbook Info and Number
                  AppCard(
                    backgroundColor: isDark
                        ? AppColors.surfaceDark
                        : AppColors.primary.withValues(alpha: 0.08),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            StatusBadge(
                              label: song.songbookCode ?? 'BE',
                              type: StatusBadgeType.primary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                song.songbookName ?? 'Buku Nyanyian',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                            StatusBadge(
                              label: 'No. ${song.number}',
                              type: StatusBadgeType.warning,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          song.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Lyrics Content Card / Reader
                  AppCard(
                    child: SelectableText(
                      song.lyrics,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.7,
                        letterSpacing: 0.2,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const AppLoadingView(message: 'Memuat lirik lagu...'),
        error: (error, stackTrace) => AppErrorView(
          message: 'Gagal memuat lirik lagu: $error',
          onRetry: () => ref.invalidate(songDetailProvider(id)),
        ),
      ),
    );
  }
}
