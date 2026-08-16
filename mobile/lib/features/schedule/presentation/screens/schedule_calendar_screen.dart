import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../domain/entities/worship_schedule.dart';
import '../providers/schedule_calendar_provider.dart';

class ScheduleCalendarScreen extends ConsumerStatefulWidget {
  const ScheduleCalendarScreen({super.key});

  @override
  ConsumerState<ScheduleCalendarScreen> createState() =>
      _ScheduleCalendarScreenState();
}

class _ScheduleCalendarScreenState
    extends ConsumerState<ScheduleCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  String _getDayName(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Senin';
      case DateTime.tuesday:
        return 'Selasa';
      case DateTime.wednesday:
        return 'Rabu';
      case DateTime.thursday:
        return 'Kamis';
      case DateTime.friday:
        return 'Jumat';
      case DateTime.saturday:
        return 'Sabtu';
      case DateTime.sunday:
      default:
        return 'Minggu';
    }
  }

  @override
  Widget build(BuildContext context) {
    final calendarAsync = ref.watch(scheduleCalendarProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender Ibadah'),
      ),
      body: ResponsiveLayout(
        maxWidth: AppBreakpoints.maxContentWidth,
        phone: calendarAsync.when(
          data: (calendarMap) {
            final selectedDayName = _selectedDay != null
                ? _getDayName(_selectedDay!)
                : _getDayName(_focusedDay);

            final selectedDaySchedules = calendarMap[selectedDayName] ?? [];

            return Column(
              children: [
                TableCalendar<WorshipSchedule>(
                  firstDay: DateTime.utc(2025, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Jadwal Hari $selectedDayName',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: selectedDaySchedules.isEmpty
                      ? AppEmptyView(
                          title: 'Tidak Ada Jadwal',
                          message:
                              'Tidak ada jadwal ibadah pada hari $selectedDayName.',
                          icon: Icons.calendar_today_outlined,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          itemCount: selectedDaySchedules.length,
                          itemBuilder: (context, index) {
                            final schedule = selectedDaySchedules[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.xs),
                              child: AppCard(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.1),
                                        borderRadius: AppRadius.borderSm,
                                      ),
                                      child: const Icon(
                                        Icons.event_rounded,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                            '${schedule.startTime} ${schedule.endTime != null ? "- ${schedule.endTime}" : ""} • ${schedule.location ?? "Gereja Utama"}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? AppColors.textSecondaryDark
                                                  : AppColors
                                                      .textSecondaryLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
          loading: () =>
              const AppLoadingView(message: 'Memuat kalender ibadah...'),
          error: (error, stack) => AppErrorView(
            message: 'Gagal memuat kalender ibadah: $error',
            onRetry: () => ref.invalidate(scheduleCalendarProvider),
          ),
        ),
      ),
    );
  }
}
