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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(donationHistoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Persembahan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Konfirmasi Persembahan',
            onPressed: () {
              context.push(RoutePaths.donationConfirm);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(donationHistoryProvider);
        },
        child: ResponsiveLayout(
          maxWidth: AppBreakpoints.maxContentWidth,
          phone: historyAsync.when(
            data: (donations) {
              if (donations.isEmpty) {
                return const AppEmptyView(
                  title: 'Belum ada riwayat persembahan',
                  message: 'Belum ada riwayat konfirmasi persembahan.',
                  icon: Icons.history_outlined,
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: donations.length,
                itemBuilder: (context, index) {
                  final donation = donations[index];
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
    );
  }
}
