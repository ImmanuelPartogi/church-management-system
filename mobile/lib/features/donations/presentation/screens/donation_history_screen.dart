import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/repositories/donation_repository_impl.dart';
import '../providers/donation_provider.dart';

class DonationHistoryScreen extends ConsumerWidget {
  const DonationHistoryScreen({super.key});

  StatusBadgeType _getStatusBadgeType(String status) {
    final lower = status.toLowerCase();
    if (lower == 'pending') return StatusBadgeType.warning;
    if (lower == 'approved') return StatusBadgeType.success;
    if (lower == 'rejected') return StatusBadgeType.error;
    return StatusBadgeType.neutral;
  }

  String _getStatusLabel(String status) {
    final lower = status.toLowerCase();
    if (lower == 'pending') return 'Menunggu Verifikasi';
    if (lower == 'approved') return 'Disetujui';
    if (lower == 'rejected') return 'Ditolak';
    return status;
  }

  String _formatAmount(num amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String _formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr);
      return DateFormat('d MMMM yyyy', 'id_ID').format(dateTime);
    } catch (_) {
      return dateStr;
    }
  }

  Future<void> _handleExport(
    BuildContext context,
    WidgetRef ref,
    String format,
  ) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          format == 'pdf'
              ? 'Menyiapkan Surat Rekapitulasi Persembahan (PDF Sah)...'
              : 'Menyiapkan spreadsheet Riwayat Persembahan (CSV)...',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    final repository = ref.read(donationRepositoryProvider);
    final filter = ref.read(donationFilterProvider);

    final result = await repository.exportDonations(
      format: format,
      startDate: filter.startDate,
      endDate: filter.endDate,
      chartOfAccountId: filter.chartOfAccountId,
      status: filter.status,
    );

    if (!context.mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      (bytes) {
        final label = format.toUpperCase();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dokumen $label (${bytes.length} bytes) siap diakses.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(donationHistoryProvider);
    final filterState = ref.watch(donationFilterProvider);
    final totalVerified = ref.watch(verifiedGivingSummaryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filterOptions = [
      {'key': 'all', 'label': 'Semua'},
      {'key': 'pending', 'label': 'Menunggu'},
      {'key': 'approved', 'label': 'Disetujui'},
      {'key': 'rejected', 'label': 'Ditolak'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Persembahan'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Ekspor Dokumen',
            onSelected: (format) => _handleExport(context, ref, format),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf_outlined, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Expanded(child: Text('Unduh Rekap Sah (PDF)')),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'csv',
                child: Row(
                  children: [
                    Icon(Icons.table_chart_outlined, color: AppColors.primaryAccent, size: 20),
                    SizedBox(width: 8),
                    Expanded(child: Text('Ekspor Riwayat (CSV)')),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Konfirmasi Persembahan',
            onPressed: () {
              context.push(RoutePaths.donationConfirm);
            },
          ),
        ],
      ),
      body: ResponsiveLayout(
        maxWidth: AppBreakpoints.maxContentWidth,
        phone: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Giving Summary Banner
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xs),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.volunteer_activism_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Terverifikasi (Tahun Berjalan)',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatAmount(totalVerified),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const StatusBadge(
                      label: 'Sah',
                      type: StatusBadgeType.success,
                      isSmall: true,
                    ),
                  ],
                ),
              ),
            ),

            // Horizontal Filter Chips
            SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
                scrollDirection: Axis.horizontal,
                itemCount: filterOptions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final option = filterOptions[index];
                  final isSelected = filterState.status == option['key'];

                  return ChoiceChip(
                    label: Text(option['label']!),
                    selected: isSelected,
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.primary : null,
                    ),
                    onSelected: (_) {
                      ref.read(donationFilterProvider.notifier).setStatus(option['key']!);
                    },
                  );
                },
              ),
            ),

            // Main List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(donationHistoryProvider);
                },
                child: historyAsync.when(
                  data: (donations) {
                    if (donations.isEmpty) {
                      return const AppEmptyView(
                        title: 'Belum ada riwayat persembahan',
                        message: 'Belum ada riwayat konfirmasi persembahan untuk filter ini.',
                        icon: Icons.history_outlined,
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: donations.length,
                      itemBuilder: (context, index) {
                        final donation = donations[index];
                        final isRejected = donation.status.toLowerCase() == 'rejected';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: AppCard(
                            onTap: () {
                              context.pushNamed(
                                RouteNames.donationDetail,
                                pathParameters: {'id': donation.id.toString()},
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      donation.donationNumber,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    StatusBadge(
                                      label: _getStatusLabel(donation.status),
                                      type: _getStatusBadgeType(donation.status),
                                      isSmall: true,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  donation.category?.name ?? 'Persembahan',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatAmount(donation.amount),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Bank: ${donation.senderBank}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                    Text(
                                      _formatDate(donation.transferDate),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                                if (isRejected &&
                                    donation.rejectionReason != null &&
                                    donation.rejectionReason!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: AppColors.error.withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.info_outline_rounded,
                                          size: 14,
                                          color: AppColors.error,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'Alasan: ${donation.rejectionReason}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.error,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const AppSkeletonListView(itemCount: 4, cardHeight: 100),
                  error: (error, stack) => AppErrorView(
                    message: 'Gagal memuat riwayat: $error',
                    onRetry: () => ref.invalidate(donationHistoryProvider),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
