import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../app/router/route_names.dart';
import '../providers/search_provider.dart';
import '../../domain/entities/global_search_result.dart';

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
      body: Column(
        children: [
          // Search Input Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Cari anggota, khotbah, lagu, warta...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 14.0,
                ),
              ),
            ),
          ),

          // Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
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
          const SizedBox(height: 12),

          // Results View
          Expanded(
            child: queryText.trim().length < 2
                ? _buildEmptyQueryHint()
                : searchAsync.when(
                    data: (result) {
                      if (result == null || result.isEmpty) {
                        return _buildNoResultsState();
                      }
                      return _buildResultList(context, result, activeFilter);
                    },
                    loading: () => _buildLoadingShimmer(),
                    error: (err, stack) => _buildErrorState(err.toString()),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, String activeFilter) {
    final isSelected = activeFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            ref.read(searchCategoryFilterProvider.notifier).state = value;
          }
        },
      ),
    );
  }

  Widget _buildEmptyQueryHint() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Ketik minimal 2 karakter untuk mencari',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Tidak ada hasil ditemukan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba kata kunci lain atau pilih kategori yang berbeda.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Gagal memuat hasil pencarian',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(globalSearchResultProvider),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      children: [
        if ((showAll || activeFilter == 'members') && result.members.isNotEmpty)
          _buildSection(
            title: 'Anggota Jemaat (${result.members.length})',
            icon: Icons.people_outline,
            children: result.members
                .map(
                  (m) => ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
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
                    leading: const CircleAvatar(
                      child: Icon(Icons.shield_outlined),
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
            icon: Icons.graphic_eq_outlined,
            children: result.sermons
                .map(
                  (s) => ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.mic)),
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
            icon: Icons.music_note_outlined,
            children: result.hymns
                .map(
                  (h) => ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        '${h.number}',
                        style: const TextStyle(fontSize: 12),
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
                    leading:
                        const CircleAvatar(child: Icon(Icons.picture_as_pdf)),
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
            icon: Icons.campaign_outlined,
            children: result.announcements
                .map(
                  (a) => ListTile(
                    leading:
                        const CircleAvatar(child: Icon(Icons.announcement)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(children: children),
        ),
      ],
    );
  }
}
