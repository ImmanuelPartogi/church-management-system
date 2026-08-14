// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FinancialPeriodModelImpl _$$FinancialPeriodModelImplFromJson(
        Map<String, dynamic> json) =>
    _$FinancialPeriodModelImpl(
      from: json['from'] as String,
      to: json['to'] as String,
    );

Map<String, dynamic> _$$FinancialPeriodModelImplToJson(
        _$FinancialPeriodModelImpl instance) =>
    <String, dynamic>{
      'from': instance.from,
      'to': instance.to,
    };

_$FinancialSummaryModelImpl _$$FinancialSummaryModelImplFromJson(
        Map<String, dynamic> json) =>
    _$FinancialSummaryModelImpl(
      totalIncome: (json['total_income'] as num).toDouble(),
      totalExpense: (json['total_expense'] as num).toDouble(),
      netBalance: (json['net_balance'] as num).toDouble(),
    );

Map<String, dynamic> _$$FinancialSummaryModelImplToJson(
        _$FinancialSummaryModelImpl instance) =>
    <String, dynamic>{
      'total_income': instance.totalIncome,
      'total_expense': instance.totalExpense,
      'net_balance': instance.netBalance,
    };

_$AccountBreakdownModelImpl _$$AccountBreakdownModelImplFromJson(
        Map<String, dynamic> json) =>
    _$AccountBreakdownModelImpl(
      accountCode: json['account_code'] as String,
      accountName: json['account_name'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
    );

Map<String, dynamic> _$$AccountBreakdownModelImplToJson(
        _$AccountBreakdownModelImpl instance) =>
    <String, dynamic>{
      'account_code': instance.accountCode,
      'account_name': instance.accountName,
      'total_amount': instance.totalAmount,
    };

_$FinancialReportModelImpl _$$FinancialReportModelImplFromJson(
        Map<String, dynamic> json) =>
    _$FinancialReportModelImpl(
      period:
          FinancialPeriodModel.fromJson(json['period'] as Map<String, dynamic>),
      summary: FinancialSummaryModel.fromJson(
          json['summary'] as Map<String, dynamic>),
      incomeBreakdown: (json['income_breakdown'] as List<dynamic>)
          .map((e) => AccountBreakdownModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      expenseBreakdown: (json['expense_breakdown'] as List<dynamic>)
          .map((e) => AccountBreakdownModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$FinancialReportModelImplToJson(
        _$FinancialReportModelImpl instance) =>
    <String, dynamic>{
      'period': instance.period,
      'summary': instance.summary,
      'income_breakdown': instance.incomeBreakdown,
      'expense_breakdown': instance.expenseBreakdown,
    };
