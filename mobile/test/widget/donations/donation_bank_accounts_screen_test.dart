import 'package:church_management_mobile/features/donations/domain/entities/church_bank_account.dart';
import 'package:church_management_mobile/features/donations/presentation/providers/donation_provider.dart';
import 'package:church_management_mobile/features/donations/presentation/screens/donation_bank_accounts_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createWidgetToTest(List<Override> overrides) {
    return ProviderScope(
      overrides: overrides,
      child: const MaterialApp(
        home: DonationBankAccountsScreen(),
      ),
    );
  }

  testWidgets('renders loading state initially', (tester) async {
    await tester.pumpWidget(
      createWidgetToTest([
        churchBankAccountsProvider.overrideWith((ref) async {
          await Future<List<ChurchBankAccount>>.delayed(
            const Duration(seconds: 2),
          );
          return [];
        }),
      ]),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders empty state when accounts list is empty',
      (tester) async {
    await tester.pumpWidget(
      createWidgetToTest([
        churchBankAccountsProvider.overrideWith((ref) async => []),
      ]),
    );

    await tester.pumpAndSettle();

    expect(
      find.text('Belum ada rekening gereja tersedia'),
      findsOneWidget,
    );
  });

  testWidgets('renders list of active church bank accounts', (tester) async {
    final mockAccounts = [
      const ChurchBankAccount(
        id: 1,
        bankName: 'Bank Central Asia (BCA)',
        accountNumber: '1234567890',
        accountHolderName: 'Gereja HKBP',
        isActive: true,
        displayOrder: 1,
      ),
      const ChurchBankAccount(
        id: 2,
        bankName: 'Bank Mandiri',
        accountNumber: '0987654321',
        accountHolderName: 'Gereja HKBP',
        isActive: true,
        displayOrder: 2,
      ),
    ];

    await tester.pumpWidget(
      createWidgetToTest([
        churchBankAccountsProvider.overrideWith((ref) async => mockAccounts),
      ]),
    );

    await tester.pumpAndSettle();

    expect(find.text('Bank Central Asia (BCA)'), findsOneWidget);
    expect(find.text('1234567890'), findsOneWidget);
    expect(find.text('Bank Mandiri'), findsOneWidget);
    expect(find.text('0987654321'), findsOneWidget);
    expect(find.text('Konfirmasi Transfer Persembahan'), findsOneWidget);
  });
}
