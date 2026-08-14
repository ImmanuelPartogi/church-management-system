import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../announcement/presentation/providers/announcement_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../schedule/presentation/providers/schedule_provider.dart';
import '../providers/daily_verse_provider.dart';
import '../../../warta/presentation/providers/warta_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final dailyVerseAsync = ref.watch(dailyVerseProvider);
    final announcementsAsync = ref.watch(announcementListProvider);
    final schedulesAsync = ref.watch(scheduleListProvider);
    final wartasAsync = ref.watch(wartaListProvider);

    final user = authState.maybeWhen(
      authenticated: (u) => u,
      orElse: () => null,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Church App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
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
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Greeting Header Card
              if (user != null)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primary,
                          child:
                              Icon(Icons.person, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Syalom, ${user.name}!',
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
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Daily Verse Section
              const Text(
                'Ayat Harian',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              dailyVerseAsync.when(
                data: (verse) => Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: AppColors.primary,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              verse.verseReference,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (verse.date != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  verse.date!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '"${verse.content}"',
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                loading: () => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
                error: (err, stack) => Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Gagal memuat ayat harian',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.red),
                          onPressed: () => ref.invalidate(dailyVerseProvider),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Upcoming Worship Schedule Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Jadwal Ibadah',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.push(RoutePaths.schedules);
                    },
                    child: const Text('Lihat semua'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              schedulesAsync.when(
                data: (schedules) {
                  if (schedules.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        'Belum ada jadwal ibadah.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  final topSchedules = schedules.take(2).toList();
                  return Column(
                    children: topSchedules.map((schedule) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: const Icon(
                              Icons.church,
                              color: AppColors.primary,
                            ),
                          ),
                          title: Text(
                            schedule.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Hari ${schedule.day} • ${schedule.startTime} ${schedule.endTime != null ? "- ${schedule.endTime}" : ""}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            context.push(RoutePaths.schedules);
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, stack) => const Text(
                  'Gagal memuat jadwal ibadah.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 24),

              // Announcements Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pengumuman Gereja',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.push(RoutePaths.announcements);
                    },
                    child: const Text('Lihat semua'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              announcementsAsync.when(
                data: (announcements) {
                  if (announcements.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        'Belum ada pengumuman.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  final topAnnouncements = announcements.take(2).toList();
                  return Column(
                    children: topAnnouncements.map((announcement) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                AppColors.secondary.withOpacity(0.1),
                            child: const Icon(
                              Icons.campaign,
                              color: AppColors.secondary,
                            ),
                          ),
                          title: Text(
                            announcement.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            announcement.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            context.push(RoutePaths.announcements);
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, stack) => const Text(
                  'Gagal memuat pengumuman.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 24),

              // Warta Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Berita/Warta Gereja',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.push(RoutePaths.wartas);
                    },
                    child: const Text('Lihat semua'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              wartasAsync.when(
                data: (wartas) {
                  if (wartas.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        'Belum ada warta gereja.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  final topWartas = wartas.take(2).toList();
                  return Column(
                    children: topWartas.map((warta) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red.shade50,
                            child: Icon(
                              Icons.picture_as_pdf,
                              color: Colors.red.shade700,
                            ),
                          ),
                          title: Text(
                            warta.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            warta.description ?? 'Warta Gereja PDF',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            context.pushNamed(
                              RouteNames.wartaDetail,
                              pathParameters: {'id': warta.id.toString()},
                            );
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, stack) => const Text(
                  'Gagal memuat warta gereja.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
