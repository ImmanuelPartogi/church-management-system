import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/announcement/presentation/screens/announcement_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/schedule/presentation/screens/schedule_calendar_screen.dart';
import '../../features/schedule/presentation/screens/schedule_screen.dart';
import '../../features/warta/presentation/screens/warta_screen.dart';
import '../../features/warta/presentation/screens/warta_detail_screen.dart';
import '../../features/warta/presentation/screens/warta_pdf_viewer_screen.dart';
import '../../features/forms/presentation/screens/service_form_types_screen.dart';
import '../../features/forms/presentation/screens/service_form_type_detail_screen.dart';
import '../../features/forms/presentation/screens/service_form_application_screen.dart';
import '../../features/forms/presentation/screens/service_form_applications_screen.dart';
import '../../features/forms/presentation/screens/service_form_application_detail_screen.dart';
import '../../features/donations/presentation/screens/donation_bank_accounts_screen.dart';
import '../../features/donations/presentation/screens/donation_confirmation_screen.dart';
import '../../features/donations/presentation/screens/donation_history_screen.dart';
import '../../features/donations/presentation/screens/donation_detail_screen.dart';
import 'route_names.dart';

class RouterTransitionListenable extends ChangeNotifier {
  RouterTransitionListenable(Ref ref) {
    ref.listen<AuthState>(
      authNotifierProvider,
      (previous, next) {
        notifyListeners();
      },
    );
  }
}

final routerTransitionListenableProvider =
    Provider<RouterTransitionListenable>((ref) {
  return RouterTransitionListenable(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(routerTransitionListenableProvider);

  return GoRouter(
    initialLocation: RoutePaths.home,
    refreshListenable: refreshListenable,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);

      final isLoggingIn = state.matchedLocation == RoutePaths.login;

      return authState.maybeWhen(
        authenticated: (_) {
          if (isLoggingIn) {
            return RoutePaths.home;
          }
          return null;
        },
        orElse: () {
          if (!isLoggingIn) {
            return RoutePaths.login;
          }
          return null;
        },
      );
    },
    routes: [
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.home,
        name: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RoutePaths.announcements,
        name: RouteNames.announcements,
        builder: (context, state) => const AnnouncementScreen(),
      ),
      GoRoute(
        path: RoutePaths.schedules,
        name: RouteNames.schedules,
        builder: (context, state) => const ScheduleScreen(),
      ),
      GoRoute(
        path: RoutePaths.schedulesCalendar,
        name: RouteNames.schedulesCalendar,
        builder: (context, state) => const ScheduleCalendarScreen(),
      ),
      GoRoute(
        path: RoutePaths.wartas,
        name: RouteNames.wartas,
        builder: (context, state) => const WartaScreen(),
      ),
      GoRoute(
        path: RoutePaths.wartaDetail,
        name: RouteNames.wartaDetail,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return WartaDetailScreen(id: id);
        },
      ),
      GoRoute(
        path: RoutePaths.wartaPdfViewer,
        name: RouteNames.wartaPdfViewer,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          final title = state.uri.queryParameters['title'] ?? 'Warta PDF';
          return WartaPdfViewerScreen(id: id, title: title);
        },
      ),
      GoRoute(
        path: RoutePaths.serviceForms,
        name: RouteNames.serviceForms,
        builder: (context, state) => const ServiceFormTypesScreen(),
      ),
      GoRoute(
        path: RoutePaths.serviceFormDetail,
        name: RouteNames.serviceFormDetail,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return ServiceFormTypeDetailScreen(id: id);
        },
      ),
      GoRoute(
        path: RoutePaths.serviceFormApply,
        name: RouteNames.serviceFormApply,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return ServiceFormApplicationScreen(id: id);
        },
      ),
      GoRoute(
        path: RoutePaths.myServiceApplications,
        name: RouteNames.myServiceApplications,
        builder: (context, state) => const ServiceFormApplicationsScreen(),
      ),
      GoRoute(
        path: RoutePaths.myServiceApplicationDetail,
        name: RouteNames.myServiceApplicationDetail,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return ServiceFormApplicationDetailScreen(id: id);
        },
      ),
      GoRoute(
        path: RoutePaths.churchBankAccounts,
        name: RouteNames.churchBankAccounts,
        builder: (context, state) => const DonationBankAccountsScreen(),
      ),
      GoRoute(
        path: RoutePaths.donationConfirm,
        name: RouteNames.donationConfirm,
        builder: (context, state) => const DonationConfirmationScreen(),
      ),
      GoRoute(
        path: RoutePaths.myDonations,
        name: RouteNames.myDonations,
        builder: (context, state) => const DonationHistoryScreen(),
      ),
      GoRoute(
        path: RoutePaths.donationDetail,
        name: RouteNames.donationDetail,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return DonationDetailScreen(id: id);
        },
      ),
    ],
  );
});
