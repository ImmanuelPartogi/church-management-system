import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/status_badge.dart';
import '../providers/sermon_provider.dart';

class SermonsScreen extends ConsumerStatefulWidget {
  const SermonsScreen({super.key});

  @override
  ConsumerState<SermonsScreen> createState() => _SermonsScreenState();
}

class _SermonsScreenState extends ConsumerState<SermonsScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(sermonSearchQueryProvider);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        ref.read(sermonSearchQueryProvider.notifier).state = value.trim();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(sermonSearchQueryProvider.notifier).state = '';
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
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
        'Agu',
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

  String _formatFileSize(int? bytes) {
    if (bytes == null || bytes <= 0) return 'PDF Document';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final sermonsAsync = ref.watch(sermonListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Arsip Khotbah & Media'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(sermonListProvider);
        },
        child: ResponsiveLayout(
          maxWidth: AppBreakpoints.maxContentWidth,
          phone: Column(
            children: [
              // Search TextField
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: SearchField(
                  controller: _searchController,
                  hintText: 'Cari judul khotbah atau nama pengkhotbah...',
                  onChanged: _onSearchChanged,
                  onClear: _clearSearch,
                ),
              ),

              // Sermons List
              Expanded(
                child: sermonsAsync.when(
                  data: (sermons) {
                    if (sermons.isEmpty) {
                      return const AppEmptyView(
                        title: 'Khotbah Tidak Ditemukan',
                        message: 'Coba kata kunci judul atau pengkhotbah lain.',
                        icon: Icons.menu_book_outlined,
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      itemCount: sermons.length,
                      itemBuilder: (context, index) {
                        final sermon = sermons[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: AppCard(
                            onTap: () {
                              context.pushNamed(
                                RouteNames.sermonDetail,
                                pathParameters: {'id': sermon.id.toString()},
                              );
                            },
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor:
                                      AppColors.primary.withValues(alpha: 0.15),
                                  child: const Icon(
                                    Icons.auto_stories,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        sermon.title,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.person_outline,
                                            size: 14,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              sermon.preacherName,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? AppColors
                                                        .textSecondaryDark
                                                    : AppColors
                                                        .textSecondaryLight,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: [
                                          StatusBadge(
                                            label:
                                                _formatDate(sermon.publishedAt),
                                            type: StatusBadgeType.neutral,
                                            isSmall: true,
                                          ),
                                          StatusBadge(
                                            label: _formatFileSize(
                                              sermon.fileSize,
                                            ),
                                            type: StatusBadgeType.info,
                                            isSmall: true,
                                          ),
                                          StatusBadge(
                                            label: '${sermon.downloadCount}',
                                            type: StatusBadgeType.success,
                                            isSmall: true,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const AppSkeletonListView(itemCount: 4, cardHeight: 90),
                  error: (error, stackTrace) => AppErrorView(
                    message: 'Gagal memuat arsip khotbah: $error',
                    onRetry: () => ref.invalidate(sermonListProvider),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
