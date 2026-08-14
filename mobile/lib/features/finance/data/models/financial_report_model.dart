import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/financial_report.dart';

part 'financial_report_model.freezed.dart';
part 'financial_report_model.g.dart';

@freezed
class FinancialPeriodModel with _$FinancialPeriodModel {
  const factory FinancialPeriodModel({
    required String from,
    required String to,
  }) = _FinancialPeriodModel;

  const FinancialPeriodModel._();

  factory FinancialPeriodModel.fromJson(Map<String, dynamic> json) =>
      _$FinancialPeriodModelFromJson(json);

  FinancialPeriod toEntity() => FinancialPeriod(from: from, to: to);
}

@freezed
class FinancialSummaryModel with _$FinancialSummaryModel {
  const factory FinancialSummaryModel({
    @JsonKey(name: 'total_income') required double totalIncome,
    @JsonKey(name: 'total_expense') required double totalExpense,
    @JsonKey(name: 'net_balance') required double netBalance,
  }) = _FinancialSummaryModel;

  const FinancialSummaryModel._();

  factory FinancialSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$FinancialSummaryModelFromJson(json);

  FinancialSummary toEntity() => FinancialSummary(
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        netBalance: netBalance,
      );
}

@freezed
class AccountBreakdownModel with _$AccountBreakdownModel {
  const factory AccountBreakdownModel({
    @JsonKey(name: 'account_code') required String accountCode,
    @JsonKey(name: 'account_name') required String accountName,
    @JsonKey(name: 'total_amount') required double totalAmount,
  }) = _AccountBreakdownModel;

  const AccountBreakdownModel._();

  factory AccountBreakdownModel.fromJson(Map<String, dynamic> json) =>
      _$AccountBreakdownModelFromJson(json);

  AccountBreakdown toEntity() => AccountBreakdown(
        accountCode: accountCode,
        accountName: accountName,
        totalAmount: totalAmount,
      );
}

@freezed
class FinancialReportModel with _$FinancialReportModel {
  const factory FinancialReportModel({
    required FinancialPeriodModel period,
    required FinancialSummaryModel summary,
    @JsonKey(name: 'income_breakdown')
    required List<AccountBreakdownModel> incomeBreakdown,
    @JsonKey(name: 'expense_breakdown')
    required List<AccountBreakdownModel> expenseBreakdown,
  }) = _FinancialReportModel;

  const FinancialReportModel._();

  factory FinancialReportModel.fromJson(Map<String, dynamic> json) =>
      _$FinancialReportModelFromJson(json);

  FinancialReport toEntity() => FinancialReport(
        period: period.toEntity(),
        summary: summary.toEntity(),
        incomeBreakdown: incomeBreakdown.map((e) => e.toEntity()).toList(),
        expenseBreakdown: expenseBreakdown.map((e) => e.toEntity()).toList(),
      );
}
