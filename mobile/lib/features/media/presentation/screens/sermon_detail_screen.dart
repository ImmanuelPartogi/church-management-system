import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/repositories/sermon_repository_impl.dart';
import '../providers/sermon_provider.dart';

class SermonDetailScreen extends ConsumerStatefulWidget {
  final int id;

  const SermonDetailScreen({
    super.key,
    required this.id,
  });

  @override
  ConsumerState<SermonDetailScreen> createState() => _SermonDetailScreenState();
}

class _SermonDetailScreenState extends ConsumerState<SermonDetailScreen> {
  bool _isDownloading = false;

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

  Future<void> _handleDownload() async {
    setState(() {
      _isDownloading = true;
    });

    final repository = ref.read(sermonRepositoryProvider);
    final result = await repository.downloadSermon(widget.id);

    if (mounted) {
      setState(() {
        _isDownloading = false;
      });

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        (downloadCount) {
          ref.invalidate(sermonDetailProvider(widget.id));
          ref.invalidate(sermonListProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dokumen khotbah berhasil diunduh / dibuka.'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sermonAsync = ref.watch(sermonDetailProvider(widget.id));

    return Scaffold(
      appBar: AppBar(
        title: sermonAsync.maybeWhen(
          data: (sermon) => Text(sermon.title),
          orElse: () => const Text('Detail Khotbah'),
        ),
      ),
      body: sermonAsync.when(
        data: (sermon) {
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
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.15),
                          child: const Icon(
                            Icons.auto_stories,
                            size: 32,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          sermon.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              sermon.preacherName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          alignment: WrapAlignment.center,
                          children: [
                            StatusBadge(
                              label: _formatDate(sermon.publishedAt),
                              type: StatusBadgeType.neutral,
                            ),
                            StatusBadge(
                              label: '${sermon.downloadCount}x diunduh',
                              type: StatusBadgeType.info,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Sermon Description / Notes Card
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ringkasan / Catatan Khotbah',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 24),
                        Text(
                          sermon.description ??
                              'Tidak ada rincian ringkasan khotbah tambahan.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: sermon.description != null
                                ? (Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight)
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Action Download / Stream Button
                  AppButton(
                    label: _isDownloading
                        ? 'Mengunduh Dokumen...'
                        : 'Unduh / Baca Dokumen Khotbah',
                    fullWidth: true,
                    isLoading: _isDownloading,
                    icon: Icons.download_rounded,
                    onPressed: _isDownloading ? null : _handleDownload,
                  ),
                ],
              ),
            ),
          );
        },
        loading: () =>
            const AppLoadingView(message: 'Memuat detail khotbah...'),
        error: (error, stackTrace) => AppErrorView(
          message: 'Gagal memuat detail khotbah: $error',
          onRetry: () => ref.invalidate(sermonDetailProvider(widget.id)),
        ),
      ),
    );
  }
}
