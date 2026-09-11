import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/status_badge.dart';
import '../providers/service_forms_provider.dart';

class ServiceFormApplicationDetailScreen extends ConsumerWidget {
  final int id;

  const ServiceFormApplicationDetailScreen({
    super.key,
    required this.id,
  });

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
    if (lower == 'draft') return 'Draf Permohonan';
    if (lower == 'pending') return 'Menunggu Verifikasi Sektor';
    if (lower == 'processing') return 'Sedang Diproses';
    if (lower == 'sector_verified') return 'Terverifikasi Sintua Sektor';
    if (lower == 'pastor_approved') return 'Disahkan Pendeta Ressort';
    if (lower == 'approved') return 'Disetujui';
    if (lower == 'completed') return 'Sakramen Selesai';
    if (lower == 'rejected') return 'Ditolak';
    return status;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final dateTime = DateTime.parse(dateStr);
      return DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(dateTime);
    } catch (_) {
      return dateStr;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationAsync =
        ref.watch(serviceFormApplicationDetailProvider(id));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengajuan'),
      ),
      body: applicationAsync.when(
        data: (app) {
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
                              app.applicationNumber,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            StatusBadge(
                              label: _getStatusLabel(app.status),
                              type: _getStatusBadgeType(app.status),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const Divider(),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          app.serviceFormType?.name ?? 'Permohonan Pelayanan',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tanggal Pengajuan: ${_formatDate(app.createdAt)}',
                              style: TextStyle(
                                fontSize: 13,
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
                  _buildSacramentTracker(app, isDark),
                  if (app.status.toLowerCase() == 'rejected' &&
                      app.rejectionReason != null &&
                      app.rejectionReason!.isNotEmpty) ...[
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
                            app.rejectionReason!,
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
                          'Catatan Pemohon',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          (app.applicantNotes != null &&
                                  app.applicantNotes!.isNotEmpty)
                              ? app.applicantNotes!
                              : 'Tidak ada catatan.',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const Divider(),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Status Pembayaran',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                            StatusBadge(
                              label: app.paymentStatus.toUpperCase(),
                              type: app.paymentStatus.toLowerCase() == 'paid'
                                  ? StatusBadgeType.success
                                  : StatusBadgeType.neutral,
                              isSmall: true,
                            ),
                          ],
                        ),
                        if (app.reviewedAt != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Ditinjau Pada',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                              Text(
                                _formatDate(app.reviewedAt),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Dokumen Pendukung',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  if (app.documents.isEmpty)
                    const AppCard(
                      child: Center(
                        child: Text(
                          'Tidak ada dokumen terlampir',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: app.documents.length,
                      itemBuilder: (context, index) {
                        final doc = app.documents[index];
                        final isPdf = doc.fileName.endsWith('.pdf');
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: AppCard(
                            child: Row(
                              children: [
                                Icon(
                                  isPdf
                                      ? Icons.picture_as_pdf_rounded
                                      : Icons.image_rounded,
                                  color:
                                      isPdf ? AppColors.error : AppColors.info,
                                  size: 24,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doc.documentName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${doc.fileName} (${_formatFileSize(doc.fileSize)})',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
        loading: () =>
            const AppLoadingView(message: 'Memuat detail pengajuan...'),
        error: (error, stack) => AppErrorView(
          message: 'Gagal memuat detail pengajuan: $error',
          onRetry: () =>
              ref.invalidate(serviceFormApplicationDetailProvider(id)),
        ),
      ),
    );
  }

  bool _isSacramentForm(dynamic app) {
    final slug = app.serviceFormType?.slug?.toLowerCase() ?? '';
    final isKnownSacrament = ['baptis', 'sidi', 'nikah'].contains(slug);
    final isSacramentStatus = [
      'sector_verified',
      'pastor_approved',
    ].contains(app.status.toLowerCase());
    return isKnownSacrament || isSacramentStatus;
  }

  Widget _buildSacramentTracker(dynamic app, bool isDark) {
    if (!_isSacramentForm(app)) return const SizedBox.shrink();

    final status = app.status.toLowerCase();
    final isRejected = status == 'rejected';

    int currentStep = 1;
    if (status == 'draft') currentStep = 0;
    if (status == 'pending') currentStep = 1;
    if (status == 'sector_verified') currentStep = 2;
    if (status == 'pastor_approved') currentStep = 3;
    if (status == 'completed' || status == 'approved') currentStep = 4;

    final steps = [
      {'title': 'Diajukan', 'subtitle': 'Permohonan berhasil dikirim jemaat'},
      {'title': 'Verifikasi Sektor', 'subtitle': 'Pemeriksaan domisili oleh Sintua Sektor'},
      {'title': 'Persetujuan Pastoral', 'subtitle': 'Pengesahan doktrinal oleh Pendeta Ressort'},
      {'title': 'Pelaksanaan Sakramen', 'subtitle': 'Sakramen dilayankan & dicatat di register'},
    ];

    return Column(
      children: [
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.account_tree_outlined, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Alur Persetujuan Sakramen',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ...List.generate(steps.length, (index) {
                final isPassed = !isRejected && currentStep > index;
                final isCurrent = !isRejected && currentStep == index;
                final isFailed = isRejected && currentStep == index;

                Color circleColor = Colors.grey.shade400;
                IconData iconData = Icons.circle_outlined;

                if (isPassed || (index == 0 && !isRejected)) {
                  circleColor = AppColors.success;
                  iconData = Icons.check_circle_rounded;
                } else if (isCurrent) {
                  circleColor = AppColors.primary;
                  iconData = Icons.radio_button_checked_rounded;
                } else if (isFailed) {
                  circleColor = AppColors.error;
                  iconData = Icons.cancel_rounded;
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Icon(iconData, color: circleColor, size: 22),
                        if (index < steps.length - 1)
                          Container(
                            width: 2,
                            height: 32,
                            color: isPassed
                                ? AppColors.success.withValues(alpha: 0.5)
                                : Colors.grey.shade300,
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              steps[index]['title']!,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: (isPassed || isCurrent) ? FontWeight.bold : FontWeight.normal,
                                color: isFailed
                                    ? AppColors.error
                                    : (isCurrent
                                        ? AppColors.primary
                                        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              steps[index]['subtitle']!,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
