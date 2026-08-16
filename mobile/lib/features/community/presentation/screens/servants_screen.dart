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
import '../providers/servant_provider.dart';

class ServantsScreen extends ConsumerStatefulWidget {
  const ServantsScreen({super.key});

  @override
  ConsumerState<ServantsScreen> createState() => _ServantsScreenState();
}

class _ServantsScreenState extends ConsumerState<ServantsScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(servantSearchQueryProvider);
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
        ref.read(servantSearchQueryProvider.notifier).state = value.trim();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(servantSearchQueryProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final servantsAsync = ref.watch(servantListProvider);
    final selectedRole = ref.watch(servantRoleFilterProvider);

    final roles = [
      {'key': null, 'label': 'Semua'},
      {'key': 'pdt_resort', 'label': 'Pendeta'},
      {'key': 'sintua', 'label': 'Sintua'},
      {'key': 'majelis', 'label': 'Majelis'},
      {'key': 'sector_leader', 'label': 'Ketua Sektor'},
      {'key': 'fellowship_leader', 'label': 'Ketua Seksi'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Direktori Pelayan Gereja'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(servantListProvider);
        },
        child: ResponsiveLayout(
          maxWidth: AppBreakpoints.maxContentWidth,
          phone: Column(
            children: [
              // Search Bar Input
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: SearchField(
                  controller: _searchController,
                  hintText: 'Cari nama pelayan...',
                  onChanged: _onSearchChanged,
                  onClear: _clearSearch,
                ),
              ),

              // Filter Chips
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: roles.length,
                  itemBuilder: (context, index) {
                    final role = roles[index];
                    final isSelected = selectedRole == role['key'];

                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(role['label'] as String),
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        checkmarkColor: AppColors.primary,
                        onSelected: (bool selected) {
                          ref.read(servantRoleFilterProvider.notifier).state =
                              selected ? role['key'] : null;
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Servants List
              Expanded(
                child: servantsAsync.when(
                  data: (servants) {
                    if (servants.isEmpty) {
                      return const AppEmptyView(
                        title: 'Pelayan Tidak Ditemukan',
                        message:
                            'Coba ubah kata kunci pencarian atau filter jabatan.',
                        icon: Icons.person_off_outlined,
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      itemCount: servants.length,
                      itemBuilder: (context, index) {
                        final servant = servants[index];
                        final initial = servant.name.isNotEmpty
                            ? servant.name[0].toUpperCase()
                            : '?';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: AppCard(
                            onTap: () {
                              context.pushNamed(
                                RouteNames.servantDetail,
                                pathParameters: {'id': servant.id.toString()},
                              );
                            },
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor:
                                      AppColors.primary.withValues(alpha: 0.15),
                                  child: Text(
                                    initial,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              servant.name,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          StatusBadge(
                                            label: servant.roleLabel,
                                            type: StatusBadgeType.info,
                                            isSmall: true,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          if (servant.sectorName != null) ...[
                                            StatusBadge(
                                              label: servant.sectorName!,
                                              type: StatusBadgeType.neutral,
                                              isSmall: true,
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                          if (servant.maskedPhone != null) ...[
                                            const Icon(
                                              Icons.phone,
                                              size: 14,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              servant.maskedPhone!,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? AppColors
                                                        .textSecondaryDark
                                                    : AppColors
                                                        .textSecondaryLight,
                                              ),
                                            ),
                                          ],
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
                      const AppSkeletonListView(itemCount: 5, cardHeight: 80),
                  error: (error, stackTrace) => AppErrorView(
                    message: 'Gagal memuat direktori pelayan: $error',
                    onRetry: () => ref.invalidate(servantListProvider),
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
