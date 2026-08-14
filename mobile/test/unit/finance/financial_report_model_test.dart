import 'package:church_management_mobile/features/finance/data/models/financial_report_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FinancialReportModel Tests', () {
    test('should parse FinancialReportModel from JSON correctly', () {
      final json = {
        'period': {
          'from': '2026-01-01',
          'to': '2026-08-14',
        },
        'summary': {
          'total_income': 15000000.0,
          'total_expense': 5000000.0,
          'net_balance': 10000000.0,
        },
        'income_breakdown': [
          {
            'account_code': '4000',
            'account_name': 'Persembahan Minggu',
            'total_amount': 10000000.0,
          },
        ],
        'expense_breakdown': [
          {
            'account_code': '5000',
            'account_name': 'Operasional Gereja',
            'total_amount': 5000000.0,
          },
        ],
      };

      final model = FinancialReportModel.fromJson(json);

      expect(model.period.from, '2026-01-01');
      expect(model.period.to, '2026-08-14');
      expect(model.summary.totalIncome, 15000000.0);
      expect(model.summary.totalExpense, 5000000.0);
      expect(model.summary.netBalance, 10000000.0);

      expect(model.incomeBreakdown.length, 1);
      expect(model.incomeBreakdown.first.accountCode, '4000');
      expect(model.incomeBreakdown.first.accountName, 'Persembahan Minggu');

      expect(model.expenseBreakdown.length, 1);
      expect(model.expenseBreakdown.first.accountCode, '5000');

      final entity = model.toEntity();
      expect(entity.summary.netBalance, 10000000.0);
      expect(entity.incomeBreakdown.first.totalAmount, 10000000.0);
    });
  });
}
