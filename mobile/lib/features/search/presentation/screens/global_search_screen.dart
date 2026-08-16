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
import '../../domain/entities/global_search_result.dart';
import '../providers/search_provider.dart';

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(searchQueryStateProvider);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        ref.read(searchQueryStateProvider.notifier).state = value;
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _debounceTimer?.cancel();
    ref.read(searchQueryStateProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final activeFilter = ref.watch(searchCategoryFilterProvider);
    final searchAsync = ref.watch(globalSearchResultProvider);
    final queryText = ref.watch(searchQueryStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pencarian Lintas Modul'),
      ),
      body: ResponsiveLayout(
        maxWidth: AppBreakpoints.maxContentWidth,
        phone: Column(
          children: [
            // Search Input Bar
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SearchField(
                controller: _searchController,
                hintText: 'Cari anggota, khotbah, lagu, warta...',
                onChanged: _onSearchChanged,
                onClear: _clearSearch,
              ),
            ),

            // Category Filter Chips
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                children: [
                  _buildFilterChip('Semua', 'all', activeFilter),
                  _buildFilterChip('Anggota', 'members', activeFilter),
                  _buildFilterChip('Pelayan', 'servants', activeFilter),
                  _buildFilterChip('Khotbah', 'sermons', activeFilter),
                  _buildFilterChip('Lagu', 'hymns', activeFilter),
                  _buildFilterChip('Warta', 'wartas', activeFilter),
                  _buildFilterChip('Pengumuman', 'announcements', activeFilter),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Results View
            Expanded(
              child: queryText.trim().length < 2
                  ? const AppEmptyView(
                      title: 'Ketik minimal 2 karakter untuk mencari',
                      message:
                          'Cari seluruh data jemaat, khotbah, lagu, dan warta.',
                      icon: Icons.search_rounded,
                    )
                  : searchAsync.when(
                      data: (result) {
                        if (result == null || result.isEmpty) {
                          return const AppEmptyView(
                            title: 'Tidak Ada Hasil',
                            message:
                                'Coba kata kunci lain atau pilih kategori yang berbeda.',
                            icon: Icons.search_off_rounded,
                          );
                        }
                        return _buildResultList(context, result, activeFilter);
                      },
                      loading: () => const AppSkeletonListView(
                        itemCount: 5,
                        cardHeight: 70,
                      ),
                      error: (err, stack) => AppErrorView(
                        message: 'Gagal memuat hasil pencarian: $err',
                        onRetry: () => ref.refresh(globalSearchResultProvider),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, String activeFilter) {
    final isSelected = activeFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        onSelected: (selected) {
          if (selected) {
            ref.read(searchCategoryFilterProvider.notifier).state = value;
          }
        },
      ),
    );
  }

  Widget _buildResultList(
    BuildContext context,
    GlobalSearchResult result,
    String activeFilter,
  ) {
    final showAll = activeFilter == 'all';

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        if ((showAll || activeFilter == 'members') && result.members.isNotEmpty)
          _buildSection(
            title: 'Anggota Jemaat (${result.members.length})',
            icon: Icons.people_outline_rounded,
            children: result.members
                .map(
                  (m) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.15),
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(m.fullName),
                    subtitle: Text(
                      m.maskedPhone ?? 'No. Anggota: ${m.membershipNumber}',
                    ),
                    onTap: () => context.push('/members/${m.id}'),
                  ),
                )
                .toList(),
          ),
        if ((showAll || activeFilter == 'servants') &&
            result.servants.isNotEmpty)
          _buildSection(
            title: 'Pelayan Gereja (${result.servants.length})',
            icon: Icons.badge_outlined,
            children: result.servants
                .map(
                  (s) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.15),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(s.name),
                    subtitle:
                        Text('${s.roleLabel} • ${s.sectorName ?? "Gereja"}'),
                    onTap: () => context.push('/servants/${s.id}'),
                  ),
                )
                .toList(),
          ),
        if ((showAll || activeFilter == 'sermons') && result.sermons.isNotEmpty)
          _buildSection(
            title: 'Arsip Khotbah (${result.sermons.length})',
            icon: Icons.graphic_eq_rounded,
            children: result.sermons
                .map(
                  (s) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.15),
                      child: const Icon(
                        Icons.mic_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(s.title),
                    subtitle: Text('Pengkhotbah: ${s.preacherName}'),
                    onTap: () => context.push('/sermons/${s.id}'),
                  ),
                )
                .toList(),
          ),
        if ((showAll || activeFilter == 'hymns') && result.hymns.isNotEmpty)
          _buildSection(
            title: 'Buku Lagu / Hymn (${result.hymns.length})',
            icon: Icons.music_note_rounded,
            children: result.hymns
                .map(
                  (h) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.15),
                      child: Text(
                        '${h.number}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    title: Text(h.title),
                    subtitle: Text(h.songbookCode ?? '', maxLines: 1),
                    onTap: () => context.push('/hymns/${h.id}'),
                  ),
                )
                .toList(),
          ),
        if ((showAll || activeFilter == 'wartas') && result.wartas.isNotEmpty)
          _buildSection(
            title: 'Warta Jemaat (${result.wartas.length})',
            icon: Icons.article_outlined,
            children: result.wartas
                .map(
                  (w) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.error.withValues(alpha: 0.15),
                      child: const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: AppColors.error,
                      ),
                    ),
                    title: Text(w.title),
                    subtitle: Text('Terbit: ${w.publishedAt}'),
                    onTap: () => context.push('/wartas/${w.id}'),
                  ),
                )
                .toList(),
          ),
        if ((showAll || activeFilter == 'announcements') &&
            result.announcements.isNotEmpty)
          _buildSection(
            title: 'Pengumuman (${result.announcements.length})',
            icon: Icons.campaign_rounded,
            children: result.announcements
                .map(
                  (a) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                      child: const Icon(
                        Icons.campaign_rounded,
                        color: AppColors.accent,
                      ),
                    ),
                    title: Text(a.title),
                    subtitle: Text(
                      a.content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => context.push(RoutePaths.announcements),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}
