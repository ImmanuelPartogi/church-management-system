import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/status_badge.dart';
import '../providers/donation_provider.dart';

class DonationDetailScreen extends ConsumerWidget {
  final int id;

  const DonationDetailScreen({
    super.key,
    required this.id,
  });

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

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final dateTime = DateTime.parse(dateStr);
      return DateFormat('d MMMM yyyy', 'id_ID').format(dateTime);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donationAsync = ref.watch(donationDetailProvider(id));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Persembahan'),
      ),
      body: donationAsync.when(
        data: (donation) {
          final isPdf = donation.proofFileUrl?.endsWith('.pdf') ?? false;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ResponsiveLayout(
              maxWidth: AppBreakpoints.detailMaxWidth,
              phone: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              donation.donationNumber,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            StatusBadge(
                              label: _getStatusLabel(donation.status),
                              type: _getStatusBadgeType(donation.status),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const Divider(),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          donation.category?.name ?? 'Persembahan',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _formatAmount(donation.amount),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildRow(
                          'Tanggal Transfer:',
                          _formatDate(donation.transferDate),
                          isDark,
                        ),
                        const SizedBox(height: 6),
                        _buildRow(
                          'Bank Pengirim:',
                          donation.senderBank,
                          isDark,
                        ),
                        if (donation.depositorPhone != null &&
                            donation.depositorPhone!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          _buildRow(
                            'No. Telepon / WA:',
                            donation.depositorPhone!,
                            isDark,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (donation.status.toLowerCase() == 'rejected' &&
                      donation.rejectionReason != null &&
                      donation.rejectionReason!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      width: double.infinity,
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
                          const Row(
                            children: [
                              Icon(
                                Icons.cancel_rounded,
                                color: AppColors.error,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Alasan Penolakan',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            donation.rejectionReason!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.error,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Catatan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          (donation.notes != null && donation.notes!.isNotEmpty)
                              ? donation.notes!
                              : 'Tidak ada catatan.',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        if (donation.reviewedAt != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          const Divider(),
                          const SizedBox(height: 6),
                          _buildRow(
                            'Diverifikasi Pada:',
                            _formatDate(donation.reviewedAt),
                            isDark,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Bukti Transfer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  if (donation.proofFileUrl == null)
                    const AppCard(
                      child: Center(
                        child: Text(
                          'Tidak ada bukti transfer terlampir',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else if (isPdf)
                    const AppCard(
                      child: Row(
                        children: [
                          Icon(
                            Icons.picture_as_pdf_rounded,
                            color: AppColors.error,
                            size: 28,
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bukti Transfer PDF',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Lampiran dokumen PDF',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  else
                    ClipRRect(
                      borderRadius: AppRadius.borderMd,
                      child: CachedNetworkImage(
                        imageUrl: donation.proofFileUrl!,
                        placeholder: (context, url) => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 180,
                          color: isDark
                              ? AppColors.surfaceDark
                              : Colors.grey.shade200,
                          child: const Center(
                            child: Text(
                              'Gagal memuat pratinjau bukti transfer',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
        loading: () => const AppLoadingView(message: 'Memuat detail donasi...'),
        error: (error, stack) => AppErrorView(
          message: 'Gagal memuat detail donasi: $error',
          onRetry: () => ref.invalidate(donationDetailProvider(id)),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
      ],
    );
  }
}
