import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/status_badge.dart';

import '../../../announcement/domain/entities/announcement.dart';
import '../../../announcement/presentation/providers/announcement_provider.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../schedule/domain/entities/worship_schedule.dart';
import '../../../schedule/presentation/providers/schedule_provider.dart';
import '../../domain/entities/daily_verse.dart';
import '../providers/daily_verse_provider.dart';
import '../../../warta/presentation/providers/warta_provider.dart';
import '../../../forms/presentation/providers/service_forms_provider.dart';
import '../../../prayer_requests/presentation/providers/prayer_request_provider.dart';
import '../../../hymns/presentation/providers/hymn_provider.dart';
import '../../../finance/presentation/providers/finance_provider.dart';
import '../../../directory/presentation/providers/member_provider.dart';
import '../../../community/presentation/providers/servant_provider.dart';
import '../../../media/presentation/providers/sermon_provider.dart';
import '../../../church/presentation/providers/tenant_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final activeChurch = ref.watch(activeChurchProvider);
    final dailyVerseAsync = ref.watch(dailyVerseProvider);
    final announcementsAsync = ref.watch(announcementListProvider);
    final schedulesAsync = ref.watch(scheduleListProvider);

    final user = authState.maybeWhen(
      authenticated: (u) => u,
      orElse: () => null,
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Church App',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            InkWell(
              onTap: () => context.push(RoutePaths.churchSelect),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 12,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 3),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 160),
                      child: Text(
                        activeChurch?.name ?? 'Pilih Gereja',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Cari',
            onPressed: () => context.push(RoutePaths.search),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'Profil Saya',
            onPressed: () => context.push(RoutePaths.profile),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Keluar',
            onPressed: () {
              ref.read(authNotifierProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dailyVerseProvider);
          ref.invalidate(announcementListProvider);
          ref.invalidate(scheduleListProvider);
          ref.invalidate(wartaListProvider);
          ref.invalidate(serviceFormTypesProvider);
          ref.invalidate(prayerRequestListProvider);
          ref.invalidate(songbooksProvider);
          ref.invalidate(hymnListProvider);
          ref.invalidate(financialReportProvider);
          ref.invalidate(memberDirectoryListProvider);
          ref.invalidate(servantListProvider);
          ref.invalidate(sermonListProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ResponsiveLayout(
            phone: _buildMainContent(
              context: context,
              ref: ref,
              user: user,
              dailyVerseAsync: dailyVerseAsync,
              announcementsAsync: announcementsAsync,
              schedulesAsync: schedulesAsync,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent({
    required BuildContext context,
    required WidgetRef ref,
    required User? user,
    required AsyncValue<DailyVerse> dailyVerseAsync,
    required AsyncValue<List<Announcement>> announcementsAsync,
    required AsyncValue<List<WorshipSchedule>> schedulesAsync,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. User Header Card
          if (user != null) ...[
            AppCard(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.surfaceDark
                  : Colors.white,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Syalom, ${user.name}! 👋',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // 2. Daily Verse Hero Section
          _buildSectionHeader(context, title: 'Ayat Harian'),
          const SizedBox(height: AppSpacing.sm),
          dailyVerseAsync.when(
            data: (verse) => Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.borderLg,
                boxShadow: AppShadows.subtle,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.menu_book_rounded,
                            color: AppColors.goldLight,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            verse.verseReference,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      if (verse.date != null)
                        StatusBadge(
                          label: verse.date!,
                          type: StatusBadgeType.neutral,
                          isSmall: true,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '"${verse.content}"',
                    style: AppTypography.scriptureStyle(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                ],
              ),
            ),
            loading: () => const AppSkeleton(height: 120),
            error: (err, _) => AppErrorView(
              message: 'Gagal memuat ayat harian',
              onRetry: () => ref.invalidate(dailyVerseProvider),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 3. Quick Actions Menu Grid
          _buildSectionHeader(context, title: 'Menu Utama'),
          const SizedBox(height: AppSpacing.sm),
          _buildQuickActionsGrid(context),
          const SizedBox(height: AppSpacing.lg),

          // 4. Upcoming Worship Schedules Timeline
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionHeader(context, title: 'Jadwal Ibadah'),
              TextButton(
                onPressed: () => context.push(RoutePaths.schedules),
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          schedulesAsync.when(
            data: (schedules) {
              if (schedules.isEmpty) {
                return const AppEmptyView(
                  title: 'Belum Ada Jadwal',
                  message: 'Jadwal ibadah terbaru belum tersedia.',
                  icon: Icons.calendar_today_outlined,
                );
              }
              final displaySchedules = schedules.take(3).toList();
              return Column(
                children: displaySchedules
                    .map((s) => _buildWorshipScheduleCard(context, s))
                    .toList(),
              );
            },
            loading: () =>
                const AppSkeletonListView(itemCount: 3, cardHeight: 80),
            error: (err, _) => AppErrorView(
              message: 'Gagal memuat jadwal ibadah',
              onRetry: () => ref.invalidate(scheduleListProvider),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 5. Announcements & Warta Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionHeader(context, title: 'Pengumuman Gereja'),
              TextButton(
                onPressed: () => context.push(RoutePaths.wartas),
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          announcementsAsync.when(
            data: (announcements) {
              if (announcements.isEmpty) {
                return const AppEmptyView(
                  title: 'Belum Ada Pengumuman',
                  message: 'Pengumuman terbaru belum tersedia.',
                );
              }
              final display = announcements.take(3).toList();
              return Column(
                children: display
                    .map((a) => _buildAnnouncementCard(context, a))
                    .toList(),
              );
            },
            loading: () =>
                const AppSkeletonListView(itemCount: 2, cardHeight: 90),
            error: (err, _) => AppErrorView(
              message: 'Gagal memuat pengumuman',
              onRetry: () => ref.invalidate(announcementListProvider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String title}) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    final actions = [
      (
        icon: Icons.article_outlined,
        label: 'Warta PDF',
        route: RoutePaths.wartas,
        color: AppColors.info
      ),
      (
        icon: Icons.music_note_outlined,
        label: 'Kidung',
        route: RoutePaths.hymns,
        color: AppColors.gold
      ),
      (
        icon: Icons.assignment_outlined,
        label: 'Formulir',
        route: RoutePaths.serviceForms,
        color: AppColors.success
      ),
      (
        icon: Icons.volunteer_activism_outlined,
        label: 'Persembahan',
        route: RoutePaths.donationConfirm,
        color: Colors.purple
      ),
      (
        icon: Icons.play_circle_outline_rounded,
        label: 'Khotbah',
        route: RoutePaths.sermons,
        color: Colors.deepOrange
      ),
      (
        icon: Icons.people_outline_rounded,
        label: 'Jemaat',
        route: RoutePaths.members,
        color: Colors.teal
      ),
      (
        icon: Icons.groups_outlined,
        label: 'Pelayan',
        route: RoutePaths.servants,
        color: Colors.indigo
      ),
      (
        icon: Icons.account_balance_outlined,
        label: 'Keuangan',
        route: RoutePaths.finance,
        color: AppColors.success
      ),
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        final item = actions[index];
        return InkWell(
          onTap: () => context.push(item.route),
          borderRadius: AppRadius.borderMd,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.1),
                  borderRadius: AppRadius.borderMd,
                ),
                child: Icon(item.icon, color: item.color, size: 24),
              ),
              const SizedBox(height: 6),
              Text(
                item.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorshipScheduleCard(
    BuildContext context,
    WorshipSchedule schedule,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: AppCard(
        onTap: () => context.push(RoutePaths.schedules),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: AppRadius.borderMd,
              ),
              child: const Icon(
                Icons.event_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schedule.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${schedule.day.startsWith('Hari') ? schedule.day : 'Hari ${schedule.day}'} • ${schedule.endTime != null && schedule.endTime!.isNotEmpty ? '${schedule.startTime} - ${schedule.endTime}' : schedule.startTime}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(
    BuildContext context,
    Announcement announcement,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: AppCard(
        onTap: () => context.push(RoutePaths.announcements),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusBadge(
                  label: announcement.status,
                  type: StatusBadgeType.info,
                  isSmall: true,
                ),
                if (announcement.publishedAt != null)
                  Text(
                    announcement.publishedAt!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              announcement.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              announcement.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
