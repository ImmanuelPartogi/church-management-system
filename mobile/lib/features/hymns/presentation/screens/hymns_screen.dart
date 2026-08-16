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
import '../providers/hymn_provider.dart';

class HymnsScreen extends ConsumerStatefulWidget {
  const HymnsScreen({super.key});

  @override
  ConsumerState<HymnsScreen> createState() => _HymnsScreenState();
}

class _HymnsScreenState extends ConsumerState<HymnsScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(hymnSearchQueryProvider);
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
        ref.read(hymnSearchQueryProvider.notifier).state = value.trim();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(hymnSearchQueryProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final songbooksAsync = ref.watch(songbooksProvider);
    final songsAsync = ref.watch(hymnListProvider);
    final currentFilter = ref.watch(hymnSongbookFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buku Nyanyian & Kidung'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(songbooksProvider);
          ref.invalidate(hymnListProvider);
        },
        child: ResponsiveLayout(
          maxWidth: AppBreakpoints.maxContentWidth,
          phone: Column(
            children: [
              // Search Input Box
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: SearchField(
                  controller: _searchController,
                  hintText: 'Cari judul, nomor, atau lirik lagu...',
                  onChanged: _onSearchChanged,
                  onClear: _clearSearch,
                ),
              ),

              // Songbook Filter Chips
              songbooksAsync.when(
                data: (songbooks) {
                  return SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: ChoiceChip(
                            label: const Text('Semua Buku'),
                            selected: currentFilter == null,
                            onSelected: (selected) {
                              if (selected) {
                                ref
                                    .read(hymnSongbookFilterProvider.notifier)
                                    .state = null;
                              }
                            },
                          ),
                        ),
                        ...songbooks.map(
                          (sb) => Padding(
                            padding:
                                const EdgeInsets.only(right: AppSpacing.sm),
                            child: ChoiceChip(
                              label: Text('${sb.code} (${sb.name})'),
                              selected: currentFilter == sb.id,
                              onSelected: (selected) {
                                ref
                                    .read(hymnSongbookFilterProvider.notifier)
                                    .state = selected ? sb.id : null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const SizedBox(height: 44),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Songs List View
              Expanded(
                child: songsAsync.when(
                  data: (songs) {
                    if (songs.isEmpty) {
                      return const AppEmptyView(
                        title: 'Lagu tidak ditemukan',
                        message:
                            'Coba kata kunci pencarian atau filter yang lain.',
                        icon: Icons.music_off_outlined,
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        final song = songs[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: AppCard(
                            onTap: () {
                              context.pushNamed(
                                RouteNames.hymnDetail,
                                pathParameters: {'id': song.id.toString()},
                              );
                            },
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: AppRadius.borderSm,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        song.songbookCode ?? 'BE',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      Text(
                                        '#${song.number}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        song.title,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        song.lyrics.split('\n').firstWhere(
                                              (line) => line.trim().isNotEmpty,
                                              orElse: () => '',
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? AppColors.textSecondaryDark
                                              : AppColors.textSecondaryLight,
                                        ),
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
                      const AppSkeletonListView(itemCount: 6, cardHeight: 70),
                  error: (error, stackTrace) => AppErrorView(
                    message: 'Gagal memuat daftar lagu: $error',
                    onRetry: () => ref.invalidate(hymnListProvider),
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
