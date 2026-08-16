import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/status_badge.dart';
import '../providers/schedule_provider.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulesAsync = ref.watch(scheduleListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Ibadah'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: 'Tampilan Kalender',
            onPressed: () {
              context.push(RoutePaths.schedulesCalendar);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(scheduleListProvider);
        },
        child: ResponsiveLayout(
          maxWidth: AppBreakpoints.maxContentWidth,
          phone: schedulesAsync.when(
            data: (schedules) {
              if (schedules.isEmpty) {
                return const AppEmptyView(
                  title: 'Belum Ada Jadwal',
                  message: 'Jadwal ibadah terbaru belum tersedia.',
                  icon: Icons.calendar_today_outlined,
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  final schedule = schedules[index];
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  schedule.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              StatusBadge(
                                label: schedule.day,
                                type: StatusBadgeType.primary,
                                isSmall: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                schedule.endTime != null
                                    ? '${schedule.startTime} - ${schedule.endTime}'
                                    : schedule.startTime,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                          if (schedule.location != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    schedule.location!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (schedule.description != null) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              schedule.description!,
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
                    ),
                  );
                },
              );
            },
            loading: () =>
                const AppSkeletonListView(itemCount: 4, cardHeight: 90),
            error: (error, stack) => AppErrorView(
              message: 'Gagal memuat jadwal ibadah: $error',
              onRetry: () => ref.invalidate(scheduleListProvider),
            ),
          ),
        ),
      ),
    );
  }
}
