import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../providers/service_forms_provider.dart';

class ServiceFormTypeDetailScreen extends ConsumerWidget {
  final int id;

  const ServiceFormTypeDetailScreen({
    super.key,
    required this.id,
  });

  String _formatFee(num amount) {
    if (amount <= 0) return 'Gratis (Tidak Dipungut Biaya)';
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormatter.format(amount);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typeAsync = ref.watch(serviceFormTypeDetailProvider(id));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pelayanan'),
      ),
      body: typeAsync.when(
        data: (type) {
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
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.15),
                              child: const Icon(
                                Icons.assignment_turned_in_rounded,
                                color: AppColors.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                type.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Text(
                          'Deskripsi Pelayanan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          (type.description != null &&
                                  type.description!.isNotEmpty)
                              ? type.description!
                              : 'Tidak ada deskripsi tambahan.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
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
                              'Biaya Administrasi',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              _formatFee(type.feeAmount),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: AppRadius.borderMd,
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: AppColors.gold),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Persiapkan dokumen pendukung yang diperlukan (format PDF, JPG, PNG max 5MB per file) sebelum mengisi formulir.',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: 'Ajukan Sekarang',
                    icon: Icons.edit_document,
                    fullWidth: true,
                    onPressed: () {
                      context.pushNamed(
                        RouteNames.serviceFormApply,
                        pathParameters: {'id': type.id.toString()},
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
        loading: () =>
            const AppLoadingView(message: 'Memuat detail formulir...'),
        error: (error, stack) => AppErrorView(
          message: 'Gagal memuat detail formulir: $error',
          onRetry: () => ref.invalidate(serviceFormTypeDetailProvider(id)),
        ),
      ),
    );
  }
}
