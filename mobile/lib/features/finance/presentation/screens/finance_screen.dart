import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../domain/entities/financial_report.dart';
import '../providers/finance_provider.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs().round();
    final str = absAmount.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }

    final formatted = 'Rp ${buffer.toString()}';
    return isNegative ? '- $formatted' : formatted;
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agt',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(financialReportProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transparansi Keuangan'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(financialReportProvider);
        },
        child: ResponsiveLayout(
          maxWidth: AppBreakpoints.maxContentWidth,
          phone: reportAsync.when(
            data: (report) {
              final totalIncome = report.summary.totalIncome;
              final totalExpense = report.summary.totalExpense;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Period Filter Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Periode Laporan',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_formatDate(report.period.from)} - ${_formatDate(report.period.to)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.filter_list_rounded,
                            color: AppColors.primary,
                          ),
                          tooltip: 'Filter Periode',
                          onSelected: (value) {
                            final now = DateTime.now();
                            if (value == 'year') {
                              final from = '${now.year}-01-01';
                              final to =
                                  '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                              ref
                                      .read(financialDateRangeProvider.notifier)
                                      .state =
                                  FinancialDateRange(from: from, to: to);
                            } else if (value == '3months') {
                              final threeMonthsAgo =
                                  now.subtract(const Duration(days: 90));
                              final from =
                                  '${threeMonthsAgo.year}-${threeMonthsAgo.month.toString().padLeft(2, '0')}-${threeMonthsAgo.day.toString().padLeft(2, '0')}';
                              final to =
                                  '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                              ref
                                      .read(financialDateRangeProvider.notifier)
                                      .state =
                                  FinancialDateRange(from: from, to: to);
                            } else if (value == 'all') {
                              ref
                                  .read(financialDateRangeProvider.notifier)
                                  .state = const FinancialDateRange();
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'year',
                              child: Text('Tahun Ini'),
                            ),
                            const PopupMenuItem(
                              value: '3months',
                              child: Text('3 Bulan Terakhir'),
                            ),
                            const PopupMenuItem(
                              value: 'all',
                              child: Text('Semua Periode'),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Net Balance Hero Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFF1E3C72)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: AppRadius.borderMd,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.account_balance_wallet_rounded,
                                color: Colors.white70,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'SALDO BERSIH GEREJA',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            _formatCurrency(report.summary.netBalance),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Income & Expense Summary Cards Grid
                    Row(
                      children: [
                        // Total Pemasukan Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: AppRadius.borderMd,
                              border: Border.all(
                                color: AppColors.success.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: AppColors.success
                                          .withValues(alpha: 0.2),
                                      child: const Icon(
                                        Icons.arrow_downward_rounded,
                                        size: 14,
                                        color: AppColors.success,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'Pemasukan',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatCurrency(totalIncome),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: AppSpacing.sm),

                        // Total Pengeluaran Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: AppRadius.borderMd,
                              border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: AppColors.error
                                          .withValues(alpha: 0.2),
                                      child: const Icon(
                                        Icons.arrow_upward_rounded,
                                        size: 14,
                                        color: AppColors.error,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'Pengeluaran',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.error,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatCurrency(totalExpense),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Income vs Expense Comparison Bar
                    if (totalIncome > 0 || totalExpense > 0) ...[
                      const Text(
                        'Rasio Perbandingan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      ClipRRect(
                        borderRadius: AppRadius.borderSm,
                        child: SizedBox(
                          height: 12,
                          child: Row(
                            children: [
                              Expanded(
                                flex: totalIncome > 0
                                    ? (totalIncome /
                                            (totalIncome + totalExpense) *
                                            100)
                                        .round()
                                    : 0,
                                child: Container(color: AppColors.success),
                              ),
                              Expanded(
                                flex: totalExpense > 0
                                    ? (totalExpense /
                                            (totalIncome + totalExpense) *
                                            100)
                                        .round()
                                    : 0,
                                child: Container(color: AppColors.error),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pemasukan (${totalIncome + totalExpense > 0 ? (totalIncome / (totalIncome + totalExpense) * 100).toStringAsFixed(1) : "0"}%)',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Pengeluaran (${totalIncome + totalExpense > 0 ? (totalExpense / (totalIncome + totalExpense) * 100).toStringAsFixed(1) : "0"}%)',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // Account Breakdown Section Header with Tabs
                    TabBar(
                      controller: _tabController,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: AppColors.primary,
                      tabs: [
                        Tab(
                          text: 'Pemasukan (${report.incomeBreakdown.length})',
                        ),
                        Tab(
                          text:
                              'Pengeluaran (${report.expenseBreakdown.length})',
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    SizedBox(
                      height: 400,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Income Breakdown List
                          _buildBreakdownList(
                            items: report.incomeBreakdown,
                            totalCategoryAmount: totalIncome,
                            isIncome: true,
                          ),

                          // Expense Breakdown List
                          _buildBreakdownList(
                            items: report.expenseBreakdown,
                            totalCategoryAmount: totalExpense,
                            isIncome: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () =>
                const AppSkeletonListView(itemCount: 4, cardHeight: 120),
            error: (error, stack) => AppErrorView(
              title: 'Gagal memuat transparansi keuangan',
              message: error.toString().replaceAll('Exception: ', ''),
              onRetry: () => ref.invalidate(financialReportProvider),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownList({
    required List<AccountBreakdown> items,
    required double totalCategoryAmount,
    required bool isIncome,
  }) {
    if (items.isEmpty) {
      return AppEmptyView(
        title: 'Belum Ada Data',
        message: isIncome
            ? 'Belum ada data pemasukan pada periode ini.'
            : 'Belum ada data pengeluaran pada periode ini.',
        icon: isIncome
            ? Icons.account_balance_outlined
            : Icons.receipt_long_outlined,
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final percentage = totalCategoryAmount > 0
            ? (item.totalAmount / totalCategoryAmount)
            : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (isIncome ? AppColors.success : AppColors.error)
                                    .withValues(alpha: 0.15),
                            borderRadius: AppRadius.borderSm,
                          ),
                          child: Text(
                            item.accountCode,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isIncome
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          item.accountName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _formatCurrency(item.totalAmount),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isIncome ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: AppRadius.borderSm,
                        child: LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isIncome ? AppColors.success : AppColors.error,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${(percentage * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
