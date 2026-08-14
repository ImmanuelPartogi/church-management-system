import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/finance_repository_impl.dart';
import '../../domain/entities/financial_report.dart';

class FinancialDateRange {
  final String? from;
  final String? to;

  const FinancialDateRange({this.from, this.to});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinancialDateRange &&
          runtimeType == other.runtimeType &&
          from == other.from &&
          to == other.to;

  @override
  int get hashCode => from.hashCode ^ to.hashCode;
}

final financialDateRangeProvider = StateProvider<FinancialDateRange>((ref) {
  return const FinancialDateRange();
});

final financialReportProvider = FutureProvider<FinancialReport>((ref) async {
  final repository = ref.watch(financeRepositoryProvider);
  final dateRange = ref.watch(financialDateRangeProvider);

  final result = await repository.getFinancialReport(
    from: dateRange.from,
    to: dateRange.to,
  );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (report) => report,
  );
});
