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
import '../providers/member_provider.dart';

class DirectoryScreen extends ConsumerStatefulWidget {
  const DirectoryScreen({super.key});

  @override
  ConsumerState<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends ConsumerState<DirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(memberSearchQueryProvider);
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
        ref.read(memberSearchQueryProvider.notifier).state = value.trim();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(memberSearchQueryProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(memberDirectoryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Direktori Jemaat'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(memberDirectoryListProvider);
        },
        child: ResponsiveLayout(
          maxWidth: AppBreakpoints.maxContentWidth,
          phone: Column(
            children: [
              // Search Input Field
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: SearchField(
                  controller: _searchController,
                  hintText: 'Cari nama jemaat atau no. anggota (MB-001)...',
                  onChanged: _onSearchChanged,
                  onClear: _clearSearch,
                ),
              ),

              // Privacy Notice Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: AppCard(
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? AppColors.surfaceDark
                          : AppColors.info.withValues(alpha: 0.08),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.security,
                        size: 18,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Kontak jemaat dilindungi dengan privasi sensorik (UU PDP).',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Member Directory List View
              Expanded(
                child: membersAsync.when(
                  data: (members) {
                    if (members.isEmpty) {
                      return const AppEmptyView(
                        title: 'Jemaat tidak ditemukan',
                        message:
                            'Coba kata kunci pencarian nama atau nomor anggota lain.',
                        icon: Icons.person_search_outlined,
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        final initial = member.fullName.isNotEmpty
                            ? member.fullName[0].toUpperCase()
                            : '?';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: AppCard(
                            onTap: () {
                              context.pushNamed(
                                RouteNames.memberDetail,
                                pathParameters: {'id': member.id.toString()},
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
                                              member.fullName,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          if (member.status != null)
                                            StatusBadge(
                                              label: member.status == 'active'
                                                  ? 'Aktif'
                                                  : member.status!,
                                              type: member.status == 'active'
                                                  ? StatusBadgeType.success
                                                  : StatusBadgeType.neutral,
                                              isSmall: true,
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          if (member.membershipNumber !=
                                              null) ...[
                                            StatusBadge(
                                              label: member.membershipNumber!,
                                              type: StatusBadgeType.neutral,
                                              isSmall: true,
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                          if (member.maskedPhone != null) ...[
                                            const Icon(
                                              Icons.phone,
                                              size: 14,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              member.maskedPhone!,
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
                    title: 'Gagal memuat direktori jemaat',
                    message: error.toString().replaceAll('Exception: ', ''),
                    onRetry: () => ref.invalidate(memberDirectoryListProvider),
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
