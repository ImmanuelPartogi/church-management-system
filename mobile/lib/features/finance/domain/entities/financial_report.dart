class FinancialPeriod {
  final String from;
  final String to;

  const FinancialPeriod({
    required this.from,
    required this.to,
  });
}

class FinancialSummary {
  final double totalIncome;
  final double totalExpense;
  final double netBalance;

  const FinancialSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
  });
}

class AccountBreakdown {
  final String accountCode;
  final String accountName;
  final double totalAmount;

  const AccountBreakdown({
    required this.accountCode,
    required this.accountName,
    required this.totalAmount,
  });
}

class FinancialReport {
  final FinancialPeriod period;
  final FinancialSummary summary;
  final List<AccountBreakdown> incomeBreakdown;
  final List<AccountBreakdown> expenseBreakdown;

  const FinancialReport({
    required this.period,
    required this.summary,
    required this.incomeBreakdown,
    required this.expenseBreakdown,
  });
}
