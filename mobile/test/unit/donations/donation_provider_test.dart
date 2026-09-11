import 'package:church_management_mobile/features/donations/domain/entities/chart_of_account.dart';
import 'package:church_management_mobile/features/donations/domain/entities/donation_confirmation.dart';
import 'package:church_management_mobile/features/donations/presentation/providers/donation_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DonationFilterNotifier Tests', () {
    test('initial state has status all and null filters', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final filter = container.read(donationFilterProvider);
      expect(filter.status, 'all');
      expect(filter.startDate, isNull);
      expect(filter.endDate, isNull);
      expect(filter.chartOfAccountId, isNull);
    });

    test('setStatus updates status correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(donationFilterProvider.notifier).setStatus('approved');
      expect(container.read(donationFilterProvider).status, 'approved');

      container.read(donationFilterProvider.notifier).setStatus('rejected');
      expect(container.read(donationFilterProvider).status, 'rejected');
    });

    test('setDateRange and clearDateRange update dates correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(donationFilterProvider.notifier)
          .setDateRange('2026-01-01', '2026-01-31');

      var filter = container.read(donationFilterProvider);
      expect(filter.startDate, '2026-01-01');
      expect(filter.endDate, '2026-01-31');

      container.read(donationFilterProvider.notifier).clearDateRange();
      filter = container.read(donationFilterProvider);
      expect(filter.startDate, isNull);
      expect(filter.endDate, isNull);
    });

    test('setCategory updates and clears chartOfAccountId correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(donationFilterProvider.notifier).setCategory(5);
      expect(container.read(donationFilterProvider).chartOfAccountId, 5);

      container.read(donationFilterProvider.notifier).setCategory(null);
      expect(container.read(donationFilterProvider).chartOfAccountId, isNull);
    });

    test('reset restores initial state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(donationFilterProvider.notifier).setStatus('pending');
      container
          .read(donationFilterProvider.notifier)
          .setDateRange('2026-01-01', '2026-01-31');
      container.read(donationFilterProvider.notifier).setCategory(3);

      container.read(donationFilterProvider.notifier).reset();
      final filter = container.read(donationFilterProvider);
      expect(filter.status, 'all');
      expect(filter.startDate, isNull);
      expect(filter.endDate, isNull);
      expect(filter.chartOfAccountId, isNull);
    });
  });

  group('verifiedGivingSummaryProvider Tests', () {
    test('calculates sum of approved donations only', () async {
      final mockList = [
        const DonationConfirmation(
          id: 1,
          donationNumber: 'DON-01',
          userId: 1,
          category: ChartOfAccount(
            id: 1,
            code: '4000',
            name: 'Persembahan',
            type: 'income',
            isActive: true,
          ),
          amount: 150000,
          transferDate: '2026-01-01',
          senderBank: 'BCA',
          status: 'approved',
          createdAt: '2026-01-01T00:00:00Z',
          updatedAt: '2026-01-01T00:00:00Z',
        ),
        const DonationConfirmation(
          id: 2,
          donationNumber: 'DON-02',
          userId: 1,
          category: ChartOfAccount(
            id: 1,
            code: '4000',
            name: 'Persembahan',
            type: 'income',
            isActive: true,
          ),
          amount: 300000,
          transferDate: '2026-01-02',
          senderBank: 'BCA',
          status: 'approved',
          createdAt: '2026-01-02T00:00:00Z',
          updatedAt: '2026-01-02T00:00:00Z',
        ),
        const DonationConfirmation(
          id: 3,
          donationNumber: 'DON-03',
          userId: 1,
          category: ChartOfAccount(
            id: 1,
            code: '4000',
            name: 'Persembahan',
            type: 'income',
            isActive: true,
          ),
          amount: 500000,
          transferDate: '2026-01-03',
          senderBank: 'BCA',
          status: 'pending',
          createdAt: '2026-01-03T00:00:00Z',
          updatedAt: '2026-01-03T00:00:00Z',
        ),
        const DonationConfirmation(
          id: 4,
          donationNumber: 'DON-04',
          userId: 1,
          category: ChartOfAccount(
            id: 1,
            code: '4000',
            name: 'Persembahan',
            type: 'income',
            isActive: true,
          ),
          amount: 1000000,
          transferDate: '2026-01-04',
          senderBank: 'BCA',
          status: 'rejected',
          createdAt: '2026-01-04T00:00:00Z',
          updatedAt: '2026-01-04T00:00:00Z',
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          donationHistoryProvider.overrideWith((ref) async => mockList),
        ],
      );
      addTearDown(container.dispose);

      // Await future to resolve async data
      await container.read(donationHistoryProvider.future);

      final summary = container.read(verifiedGivingSummaryProvider);
      // 150,000 + 300,000 = 450,000 (pending and rejected excluded)
      expect(summary, 450000);
    });

    test('returns 0 when history is empty or loading', () {
      final container = ProviderContainer(
        overrides: [
          donationHistoryProvider.overrideWith((ref) async => []),
        ],
      );
      addTearDown(container.dispose);

      final summary = container.read(verifiedGivingSummaryProvider);
      expect(summary, 0);
    });
  });
}
