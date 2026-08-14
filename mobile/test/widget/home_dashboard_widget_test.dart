import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:church_management_mobile/features/announcement/domain/entities/announcement.dart';
import 'package:church_management_mobile/features/announcement/presentation/providers/announcement_provider.dart';
import 'package:church_management_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:church_management_mobile/features/home/domain/entities/daily_verse.dart';
import 'package:church_management_mobile/features/home/presentation/providers/daily_verse_provider.dart';
import 'package:church_management_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:church_management_mobile/features/schedule/domain/entities/worship_schedule.dart';
import 'package:church_management_mobile/features/schedule/presentation/providers/schedule_provider.dart';

import 'login_screen_test.dart';

void main() {
  group('HomeScreen Dashboard Widget Tests', () {
    const testVerse = DailyVerse(
      id: 1,
      verseReference: 'Filipi 4:13',
      content:
          'Segala perkara dapat kutanggung di dalam Dia yang memberi kekuatan kepadaku.',
      date: '2026-08-13',
    );

    const testAnnouncements = [
      Announcement(
        id: 1,
        title: 'Pengumuman Seminar Jemaat',
        content: 'Seminar dilaksanakan Sabtu mendatang.',
        status: 'published',
      ),
    ];

    const testSchedules = [
      WorshipSchedule(
        id: 1,
        title: 'Ibadah Minggu Pagi',
        day: 'Minggu',
        startTime: '08:00',
        endTime: '10:00',
        location: 'Gereja Utama',
        active: true,
      ),
    ];

    Widget createHomeScreenUnderTest() {
      return ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          dailyVerseProvider.overrideWith((ref) async => testVerse),
          announcementListProvider
              .overrideWith((ref) async => testAnnouncements),
          scheduleListProvider.overrideWith((ref) async => testSchedules),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      );
    }

    testWidgets(
        'renders Daily Verse, Worship Schedule, and Announcements cards cleanly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreenUnderTest());
      await tester.pumpAndSettle();

      // Verify Headers
      expect(find.text('Church App'), findsOneWidget);
      expect(find.text('Ayat Harian'), findsOneWidget);
      expect(find.text('Jadwal Ibadah'), findsOneWidget);
      expect(find.text('Pengumuman Gereja'), findsOneWidget);

      // Verify Daily Verse Content
      expect(find.text('Filipi 4:13'), findsOneWidget);
      expect(
        find.text(
          '"Segala perkara dapat kutanggung di dalam Dia yang memberi kekuatan kepadaku."',
        ),
        findsOneWidget,
      );

      // Verify Worship Schedule Content
      expect(find.text('Ibadah Minggu Pagi'), findsOneWidget);
      expect(find.text('Hari Minggu • 08:00 - 10:00'), findsOneWidget);

      // Verify Announcement Content
      expect(find.text('Pengumuman Seminar Jemaat'), findsOneWidget);
      expect(
        find.text('Seminar dilaksanakan Sabtu mendatang.'),
        findsOneWidget,
      );
    });
  });
}
