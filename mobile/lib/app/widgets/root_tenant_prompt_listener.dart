import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/church/presentation/providers/tenant_provider.dart';
import '../../features/church/presentation/widgets/multi_membership_selection_sheet.dart';
import '../router/app_router.dart';

/// Wraps the root MaterialApp to listen for multi-membership selection prompts
/// globally across all screens in the application.
class RootTenantPromptListener extends ConsumerWidget {
  final Widget child;

  const RootTenantPromptListener({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<TenantState>(tenantProvider, (previous, next) {
      if (next.promptMultiMembershipSelection) {
        final authState = ref.read(authNotifierProvider);
        final user = authState.maybeWhen(
          authenticated: (u) => u,
          orElse: () => null,
        );

        if (user != null && user.memberships.length >= 2) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final navContext = rootNavigatorKey.currentContext;
            if (navContext != null && navContext.mounted) {
              showMultiMembershipSelectionSheet(navContext, ref, user);
            }
          });
        }
      }
    });

    return child;
  }
}
