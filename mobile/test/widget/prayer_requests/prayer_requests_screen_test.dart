import 'package:church_management_mobile/features/prayer_requests/domain/entities/prayer_request.dart';
import 'package:church_management_mobile/features/prayer_requests/presentation/providers/prayer_request_provider.dart';
import 'package:church_management_mobile/features/prayer_requests/presentation/screens/prayer_requests_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createWidgetToTest(List<Override> overrides) {
    return ProviderScope(
      overrides: overrides,
      child: const MaterialApp(
        home: PrayerRequestsScreen(),
      ),
    );
  }

  testWidgets('renders empty state when prayer request list is empty',
      (tester) async {
    await tester.pumpWidget(
      createWidgetToTest([
        prayerRequestListProvider.overrideWith((ref) async => []),
      ]),
    );

    await tester.pumpAndSettle();

    expect(find.text('Belum Ada Permohonan Doa'), findsOneWidget);
    expect(find.text('Ajukan Pokok Doa Baru'), findsOneWidget);
  });

  testWidgets(
      'renders list of user prayer requests with status & privacy badges',
      (tester) async {
    final mockRequests = [
      const PrayerRequest(
        id: 1,
        userId: 2,
        title: 'Doa Pemulihan Kesehatan',
        content: 'Mohon doa untuk orang tua yang sedang dirawat.',
        category: 'Kesehatan',
        isPrivate: true,
        status: 'submitted',
        createdAt: '2026-08-14T10:00:00.000000Z',
        updatedAt: '2026-08-14T10:00:00.000000Z',
      ),
      const PrayerRequest(
        id: 2,
        userId: 2,
        title: 'Doa Syukur Keluarga',
        content: 'Mengucapkan syukur atas berkat Tuhan.',
        category: 'Ucapan Syukur',
        isPrivate: false,
        status: 'followed_up',
        followUpNotes: 'Telah didoakan oleh Pendeta.',
        followedUpAt: '2026-08-14T12:00:00.000000Z',
        createdAt: '2026-08-14T11:00:00.000000Z',
        updatedAt: '2026-08-14T12:00:00.000000Z',
      ),
    ];

    await tester.pumpWidget(
      createWidgetToTest([
        prayerRequestListProvider.overrideWith((ref) async => mockRequests),
      ]),
    );

    await tester.pumpAndSettle();

    expect(find.text('Doa Pemulihan Kesehatan'), findsOneWidget);
    expect(find.text('Doa Syukur Keluarga'), findsOneWidget);
    expect(find.text('Menunggu Didoakan'), findsOneWidget);
    expect(find.text('Sudah Ditindaklanjuti'), findsOneWidget);
    expect(find.text('Privat'), findsOneWidget);
    expect(find.text('Publik'), findsOneWidget);
    expect(find.text('Ada Tanggapan'), findsOneWidget);
  });
}
