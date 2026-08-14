import 'package:church_management_mobile/core/error/failures.dart';
import 'package:church_management_mobile/features/finance/data/repositories/finance_repository_impl.dart';
import 'package:church_management_mobile/features/finance/domain/entities/financial_report.dart';
import 'package:church_management_mobile/features/finance/domain/repositories/finance_repository.dart';
import 'package:church_management_mobile/features/finance/presentation/screens/finance_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

class FakeFinanceRepository implements FinanceRepository {
  final FinancialReport? report;
  final String? errorMessage;

  FakeFinanceRepository({this.report, this.errorMessage});

  @override
  Future<Either<Failure, FinancialReport>> getFinancialReport({
    String? from,
    String? to,
  }) async {
    if (errorMessage != null) {
      return Left(ServerFailure(errorMessage!));
    }
    return Right(
      report ??
          const FinancialReport(
            period: FinancialPeriod(from: '2026-01-01', to: '2026-08-14'),
            summary: FinancialSummary(
              totalIncome: 15000000.0,
              totalExpense: 5000000.0,
              netBalance: 10000000.0,
            ),
            incomeBreakdown: [
              AccountBreakdown(
                accountCode: '4000',
                accountName: 'Persembahan Minggu',
                totalAmount: 15000000.0,
              ),
            ],
            expenseBreakdown: [
              AccountBreakdown(
                accountCode: '5000',
                accountName: 'Operasional Gereja',
                totalAmount: 5000000.0,
              ),
            ],
          ),
    );
  }
}

void main() {
  Widget createWidgetToTest(FakeFinanceRepository repo) {
    return ProviderScope(
      overrides: [
        financeRepositoryProvider.overrideWithValue(repo),
      ],
      child: const MaterialApp(
        home: FinanceScreen(),
      ),
    );
  }

  testWidgets('renders summary cards and net balance cleanly', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final repo = FakeFinanceRepository();

    await tester.pumpWidget(createWidgetToTest(repo));
    await tester.pumpAndSettle();

    expect(find.text('Transparansi Keuangan'), findsOneWidget);
    expect(find.text('SALDO BERSIH GEREJA'), findsOneWidget);
    expect(find.text('Rp 10.000.000'), findsOneWidget);
    expect(find.text('Pemasukan'), findsOneWidget);
    expect(find.text('Rp 15.000.000'), findsNWidgets(2));
    expect(find.text('Pengeluaran'), findsOneWidget);
    expect(find.text('Rp 5.000.000'), findsOneWidget);
  });

  testWidgets('renders error state when repo throws failure', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final repo = FakeFinanceRepository(errorMessage: 'Koneksi terputus');

    await tester.pumpWidget(createWidgetToTest(repo));
    await tester.pumpAndSettle();

    expect(find.text('Gagal memuat transparansi keuangan'), findsOneWidget);
    expect(find.text('Koneksi terputus'), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);
  });
}
