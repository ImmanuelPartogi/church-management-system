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
  });

  testWidgets('renders personal donation history list with status badges',
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
    ];

    await tester.pumpWidget(
      createWidgetToTest([
        donationHistoryProvider.overrideWith((ref) async => mockDonations),
      ]),
    );

    await tester.pumpAndSettle();

    expect(find.text('DON-20260814-001'), findsOneWidget);
    expect(find.text('DON-20260814-002'), findsOneWidget);
    expect(find.text('Persembahan Minggu'), findsOneWidget);
    expect(find.text('Persepuluhan'), findsOneWidget);
    expect(find.text('Rp 100.000'), findsOneWidget);
    expect(find.text('Rp 500.000'), findsOneWidget);
    expect(find.text('Menunggu Verifikasi'), findsOneWidget);
    expect(find.text('Disetujui'), findsOneWidget);
  });
}
