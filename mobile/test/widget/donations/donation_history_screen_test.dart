import 'package:church_management_mobile/features/donations/domain/entities/chart_of_account.dart';
import 'package:church_management_mobile/features/donations/domain/entities/donation_confirmation.dart';
import 'package:church_management_mobile/features/donations/presentation/providers/donation_provider.dart';
import 'package:church_management_mobile/features/donations/presentation/screens/donation_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createWidgetToTest(List<Override> overrides) {
    return ProviderScope(
      overrides: overrides,
      child: const MaterialApp(
        home: DonationHistoryScreen(),
      ),
    );
  }

  testWidgets('renders empty state when donation history is empty',
      (tester) async {
    await tester.pumpWidget(
      createWidgetToTest([
        donationHistoryProvider.overrideWith((ref) async => []),
      ]),
    );

    await tester.pumpAndSettle();

    expect(
      find.text('Belum ada riwayat persembahan'),
      findsOneWidget,
    );
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Menunggu'), findsOneWidget);
    expect(find.text('Disetujui'), findsOneWidget);
    expect(find.text('Ditolak'), findsOneWidget);
  });

  testWidgets('renders personal donation history list with status badges, summary, and filter chips',
      (tester) async {
    final mockDonations = [
      const DonationConfirmation(
        id: 1,
        donationNumber: 'DON-20260814-001',
        userId: 2,
        category: ChartOfAccount(
          id: 1,
          code: '4000',
          name: 'Persembahan Minggu',
          type: 'income',
          isActive: true,
        ),
        amount: 100000,
        transferDate: '2026-08-14',
        senderBank: 'BCA',
        status: 'pending',
        createdAt: '2026-08-14T10:00:00.000000Z',
        updatedAt: '2026-08-14T10:00:00.000000Z',
      ),
      const DonationConfirmation(
        id: 2,
        donationNumber: 'DON-20260814-002',
        userId: 2,
        category: ChartOfAccount(
          id: 2,
          code: '4100',
          name: 'Persepuluhan',
          type: 'income',
          isActive: true,
        ),
        amount: 500000,
        transferDate: '2026-08-14',
        senderBank: 'Mandiri',
        status: 'approved',
        createdAt: '2026-08-14T11:00:00.000000Z',
        updatedAt: '2026-08-14T11:00:00.000000Z',
      ),
      const DonationConfirmation(
        id: 3,
        donationNumber: 'DON-20260814-003',
        userId: 2,
        category: ChartOfAccount(
          id: 1,
          code: '4000',
          name: 'Persembahan Minggu',
          type: 'income',
          isActive: true,
        ),
        amount: 250000,
        transferDate: '2026-08-15',
        senderBank: 'BRI',
        status: 'rejected',
        rejectionReason: 'Bukti transfer buram tidak terbaca',
        createdAt: '2026-08-15T09:00:00.000000Z',
        updatedAt: '2026-08-15T09:30:00.000000Z',
      ),
    ];

    await tester.pumpWidget(
      createWidgetToTest([
        donationHistoryProvider.overrideWith((ref) async => mockDonations),
      ]),
    );

    await tester.pumpAndSettle();

    // Verify list items
    expect(find.text('DON-20260814-001'), findsOneWidget);
    expect(find.text('DON-20260814-002'), findsOneWidget);
    expect(find.text('DON-20260814-003'), findsOneWidget);
    expect(find.text('Persepuluhan'), findsOneWidget);
    expect(find.text('Rp 100.000'), findsOneWidget);
    expect(find.text('Rp 250.000'), findsOneWidget);
    expect(find.text('Menunggu Verifikasi'), findsOneWidget);
    expect(find.text('Disetujui'), findsNWidgets(2)); // One in ChoiceChip, one on StatusBadge
    expect(find.text('Ditolak'), findsNWidgets(2)); // One in ChoiceChip, one on StatusBadge

    // Verify rejection reason callout
    expect(find.text('Alasan: Bukti transfer buram tidak terbaca'), findsOneWidget);

    // Verify Giving Summary card shows approved total
    expect(find.text('Total Terverifikasi (Tahun Berjalan)'), findsOneWidget);
    expect(find.text('Rp 500.000'), findsWidgets);

    // Verify filter chips are rendered
    expect(find.byType(ChoiceChip), findsNWidgets(4));
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Menunggu'), findsOneWidget);

    // Verify export button opens popup menu
    final exportButton = find.byIcon(Icons.file_download_outlined);
    expect(exportButton, findsOneWidget);
    await tester.tap(exportButton);
    await tester.pumpAndSettle();

    expect(find.text('Unduh Rekap Sah (PDF)'), findsOneWidget);
    expect(find.text('Ekspor Riwayat (CSV)'), findsOneWidget);
  });
}
