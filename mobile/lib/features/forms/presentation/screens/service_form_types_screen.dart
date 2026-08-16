import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/status_badge.dart';
import '../providers/service_forms_provider.dart';

class ServiceFormTypesScreen extends ConsumerWidget {
  const ServiceFormTypesScreen({super.key});

  String _formatFee(num amount) {
    if (amount <= 0) return 'Gratis';
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormatter.format(amount);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typesAsync = ref.watch(serviceFormTypesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulir Pelayanan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Riwayat Pengajuan',
            onPressed: () {
              context.push(RoutePaths.myServiceApplications);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(serviceFormTypesProvider);
        },
        child: ResponsiveLayout(
          maxWidth: AppBreakpoints.maxContentWidth,
          phone: typesAsync.when(
            data: (types) {
              if (types.isEmpty) {
                return const AppEmptyView(
                  title: 'Belum ada jenis formulir pelayanan tersedia',
                  message:
                      'Belum ada jenis formulir pelayanan tersedia saat ini.',
                  icon: Icons.assignment_outlined,
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: types.length,
                itemBuilder: (context, index) {
                  final type = types[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AppCard(
                      onTap: () {
                        context.pushNamed(
                          RouteNames.serviceFormDetail,
                          pathParameters: {'id': type.id.toString()},
                        );
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: AppRadius.borderSm,
                            ),
                            child: const Icon(
                              Icons.assignment_rounded,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  type.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (type.description != null &&
                                    type.description!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    type.description!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: AppSpacing.xs),
                                StatusBadge(
                                  label: 'Biaya: ${_formatFee(type.feeAmount)}',
                                  type: type.feeAmount <= 0
                                      ? StatusBadgeType.success
                                      : StatusBadgeType.info,
                                  isSmall: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const AppLoadingView(useSkeleton: false),
            error: (error, stack) => AppErrorView(
              message: 'Gagal memuat formulir: $error',
              onRetry: () => ref.invalidate(serviceFormTypesProvider),
            ),
          ),
        ),
      ),
    );
  }
}
