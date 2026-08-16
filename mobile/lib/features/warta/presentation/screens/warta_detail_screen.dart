import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/status_badge.dart';
import '../providers/warta_provider.dart';

class WartaDetailScreen extends ConsumerWidget {
  final int id;

  const WartaDetailScreen({
    super.key,
    required this.id,
  });

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
    final wartaAsync = ref.watch(wartaDetailProvider(id));
    final downloadState = ref.watch(wartaDownloadProvider(id));

    // Listen to download status changes
    ref.listen<DownloadState>(wartaDownloadProvider(id), (previous, next) {
      if (next.status == DownloadStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Warta berhasil diunduh'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(wartaDownloadProvider(id).notifier).reset();
        ref.invalidate(wartaDetailProvider(id));
      } else if (next.status == DownloadStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Gagal mengunduh warta'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(wartaDownloadProvider(id).notifier).reset();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Warta'),
      ),
      body: wartaAsync.when(
        data: (warta) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ResponsiveLayout(
              maxWidth: AppBreakpoints.detailMaxWidth,
              phone: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header card
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: AppRadius.borderSm,
                              ),
                              child: const Icon(
                                Icons.picture_as_pdf_rounded,
                                color: AppColors.error,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                warta.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            StatusBadge(
                              label: _formatDate(warta.publishedAt),
                              type: StatusBadgeType.neutral,
                            ),
                            StatusBadge(
                              label: '${warta.downloadCount} kali diunduh',
                              type: StatusBadgeType.info,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Description section
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Deskripsi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 24),
                        Text(
                          (warta.description != null &&
                                  warta.description!.isNotEmpty)
                              ? warta.description!
                              : 'Tidak ada deskripsi untuk warta ini.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: warta.description != null
                                ? (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight)
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // File metadata details
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informasi File',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 24),
                        _buildRow('Nama File', warta.fileName, isDark),
                        const SizedBox(height: AppSpacing.xs),
                        _buildRow(
                          'Ukuran File',
                          _formatFileSize(warta.fileSize),
                          isDark,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        _buildRow(
                          'Format',
                          warta.mimeType.split('/').last.toUpperCase(),
                          isDark,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Actions
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppButton(
                        label: 'Baca Warta',
                        icon: Icons.menu_book_rounded,
                        fullWidth: true,
                        onPressed: downloadState.status ==
                                DownloadStatus.downloading
                            ? null
                            : () {
                                context.pushNamed(
                                  RouteNames.wartaPdfViewer,
                                  pathParameters: {'id': warta.id.toString()},
                                  queryParameters: {'title': warta.title},
                                );
                              },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppButton(
                        label:
                            downloadState.status == DownloadStatus.downloading
                                ? 'Mengunduh...'
                                : 'Download Warta',
                        icon: Icons.download_rounded,
                        fullWidth: true,
                        variant: AppButtonVariant.outlined,
                        isLoading: false,
                        onPressed: downloadState.status ==
                                DownloadStatus.downloading
                            ? null
                            : () {
                                ref
                                    .read(wartaDownloadProvider(id).notifier)
                                    .download(
                                      fileName: warta.fileName,
                                    );
                              },
                      ),
                      if (downloadState.status ==
                          DownloadStatus.downloading) ...[
                        const SizedBox(height: AppSpacing.sm),
                        LinearProgressIndicator(
                          value: downloadState.progress,
                          backgroundColor: Colors.grey.shade200,
                          valueColor:
                              const AlwaysStoppedAnimation(AppColors.primary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mengunduh: ${(downloadState.progress * 100).toStringAsFixed(0)}%',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const AppLoadingView(message: 'Memuat detail warta...'),
        error: (error, stack) => AppErrorView(
          message: 'Gagal memuat detail warta: $error',
          onRetry: () => ref.invalidate(wartaDetailProvider(id)),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            fontSize: 13,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
