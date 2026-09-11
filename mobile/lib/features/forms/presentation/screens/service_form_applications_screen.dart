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
import '../providers/service_forms_provider.dart';

class ServiceFormApplicationsScreen extends ConsumerWidget {
  const ServiceFormApplicationsScreen({super.key});

  StatusBadgeType _getStatusBadgeType(String status) {
    final lower = status.toLowerCase();
    if (lower == 'draft') return StatusBadgeType.neutral;
    if (lower == 'pending') return StatusBadgeType.warning;
    if (lower == 'processing') return StatusBadgeType.info;
    if (lower == 'sector_verified') return StatusBadgeType.info;
    if (lower == 'pastor_approved') return StatusBadgeType.success;
    if (lower == 'approved') return StatusBadgeType.success;
    if (lower == 'completed') return StatusBadgeType.success;
    if (lower == 'rejected') return StatusBadgeType.error;
    return StatusBadgeType.neutral;
  }

  String _getStatusLabel(String status) {
    final lower = status.toLowerCase();
    if (lower == 'pending') return 'Pending';
    if (lower == 'draft') return 'Draf';
    if (lower == 'processing') return 'Diproses';
    if (lower == 'sector_verified') return 'Verifikasi Sektor';
    if (lower == 'pastor_approved') return 'Disetujui Pendeta';
    if (lower == 'approved') return 'Disetujui';
    if (lower == 'completed') return 'Selesai';
    if (lower == 'rejected') return 'Ditolak';
    return status;
  }

  String _formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr);
      return DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(dateTime);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync = ref.watch(serviceFormApplicationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pengajuan'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(serviceFormApplicationsProvider);
        },
        child: ResponsiveLayout(
          maxWidth: AppBreakpoints.maxContentWidth,
          phone: applicationsAsync.when(
            data: (applications) {
              if (applications.isEmpty) {
                return const AppEmptyView(
                  title: 'Belum ada riwayat permohonan pelayanan',
                  message: 'Belum ada riwayat permohonan pelayanan.',
                  icon: Icons.history_outlined,
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: applications.length,
                itemBuilder: (context, index) {
                  final app = applications[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AppCard(
                      onTap: () {
                        context.pushNamed(
                          RouteNames.myServiceApplicationDetail,
                          pathParameters: {'id': app.id.toString()},
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                app.applicationNumber,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              StatusBadge(
                                label: _getStatusLabel(app.status),
                                type: _getStatusBadgeType(app.status),
                                isSmall: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            app.serviceFormType?.name ?? 'Permohonan Pelayanan',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatDate(app.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                              const Spacer(),
                              if (app.documents.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.attach_file_rounded,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${app.documents.length} berkas',
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
              onRetry: () => ref.invalidate(serviceFormApplicationsProvider),
            ),
          ),
        ),
      ),
    );
  }
}
