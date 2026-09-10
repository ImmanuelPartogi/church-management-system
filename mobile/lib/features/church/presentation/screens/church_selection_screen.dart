import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/repositories/church_repository_impl.dart';
import '../../domain/entities/church.dart';
import '../providers/tenant_provider.dart';

final churchesListProvider = FutureProvider.autoDispose<List<Church>>((ref) async {
  final repo = ref.watch(churchRepositoryProvider);
  final result = await repo.getChurches();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (churches) => churches,
  );
});

class ChurchSelectionScreen extends ConsumerStatefulWidget {
  const ChurchSelectionScreen({super.key});

  @override
  ConsumerState<ChurchSelectionScreen> createState() =>
      _ChurchSelectionScreenState();
}

class _ChurchSelectionScreenState extends ConsumerState<ChurchSelectionScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final churchesAsync = ref.watch(churchesListProvider);
    final activeChurch = ref.watch(activeChurchProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Gereja'),
      ),
      body: ResponsiveLayout(
        maxWidth: 600,
        phone: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: AppTextField(
                controller: _searchController,
                hintText: 'Cari nama gereja atau kota...',
                prefixIcon: Icons.search_rounded,
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                onChanged: (val) {
                  setState(() => _searchQuery = val.trim().toLowerCase());
                },
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(churchesListProvider);
                },
                child: churchesAsync.when(
                  data: (churches) {
                    final filtered = churches.where((c) {
                      if (_searchQuery.isEmpty) return true;
                      final nameMatch =
                          c.name.toLowerCase().contains(_searchQuery);
                      final addressMatch = c.address
                              ?.toLowerCase()
                              .contains(_searchQuery) ??
                          false;
                      return nameMatch || addressMatch;
                    }).toList();

                    if (filtered.isEmpty) {
                      return AppEmptyView(
                        title: 'Gereja Tidak Ditemukan',
                        message: _searchQuery.isEmpty
                            ? 'Belum ada gereja aktif yang terdaftar di platform.'
                            : 'Tidak ada gereja yang cocok dengan kata kunci "$_searchQuery".',
                        icon: Icons.church_outlined,
                      );
                    }

                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final church = filtered[index];
                        final isSelected = activeChurch?.id == church.id;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: AppCard(
                            onTap: () async {
                              await ref
                                  .read(tenantProvider.notifier)
                                  .selectChurch(church);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Gereja aktif diubah ke ${church.name}',
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                              if (context.mounted) {
                                await Navigator.of(context).maybePop();
                              }
                            },
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: isSelected
                                      ? AppColors.primary
                                      : (isDark
                                          ? AppColors.surfaceVariantDark
                                          : const Color(0xFFE2E8F0)),
                                  child: Icon(
                                    Icons.church_rounded,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.primary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              church.name,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          if (isSelected)
                                            const StatusBadge(
                                              label: 'Aktif',
                                              type: StatusBadgeType.success,
                                              isSmall: true,
                                            ),
                                        ],
                                      ),
                                      if (church.address != null &&
                                          church.address!.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          church.address!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark
                                                ? AppColors.textSecondaryDark
                                                : AppColors.textSecondaryLight,
                                          ),
                                        ),
                                      ],
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
                  loading: () => const AppSkeletonListView(
                    itemCount: 4,
                    cardHeight: 80,
                  ),
                  error: (error, _) => AppErrorView(
                    title: 'Gagal Memuat Daftar Gereja',
                    message: error.toString().replaceAll('Exception: ', ''),
                    onRetry: () => ref.invalidate(churchesListProvider),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
