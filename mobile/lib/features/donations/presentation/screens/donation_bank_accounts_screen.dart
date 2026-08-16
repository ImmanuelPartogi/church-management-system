import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../providers/donation_provider.dart';

class DonationBankAccountsScreen extends ConsumerWidget {
  const DonationBankAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(churchBankAccountsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekening Persembahan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Riwayat Donasi',
            onPressed: () {
              context.push(RoutePaths.myDonations);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(churchBankAccountsProvider);
        },
        child: ResponsiveLayout(
          maxWidth: AppBreakpoints.maxContentWidth,
          phone: accountsAsync.when(
            data: (accounts) {
              if (accounts.isEmpty) {
                return const AppEmptyView(
                  title: 'Belum ada rekening gereja tersedia',
                  message: 'Rekening bank gereja belum didaftarkan.',
                  icon: Icons.account_balance_outlined,
                );
              }
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: accounts.length,
                      itemBuilder: (context, index) {
                        final acc = accounts[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppColors.primary
                                          .withValues(alpha: 0.15),
                                      child: const Icon(
                                        Icons.account_balance_rounded,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text(
                                      acc.bankName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  'Nomor Rekening:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SelectableText(
                                      acc.accountNumber,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.copy_rounded),
                                      tooltip: 'Salin Rekening',
                                      color: AppColors.primary,
                                      onPressed: () {
                                        Clipboard.setData(
                                          ClipboardData(
                                            text: acc.accountNumber,
                                          ),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Nomor rekening ${acc.bankName} berhasil disalin!',
                                            ),
                                            duration:
                                                const Duration(seconds: 2),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Atas Nama: ${acc.accountHolderName}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: AppButton(
                      label: 'Konfirmasi Transfer Persembahan',
                      icon: Icons.send_rounded,
                      fullWidth: true,
                      onPressed: () {
                        context.push(RoutePaths.donationConfirm);
                      },
                    ),
                  ),
                ],
              );
            },
            loading: () => const AppLoadingView(useSkeleton: false),
            error: (error, stack) => AppErrorView(
              message: 'Gagal memuat rekening: $error',
              onRetry: () => ref.invalidate(churchBankAccountsProvider),
            ),
          ),
        ),
      ),
    );
  }
}
