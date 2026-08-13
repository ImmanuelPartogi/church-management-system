import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/announcement/presentation/screens/announcement_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/schedule/presentation/screens/schedule_calendar_screen.dart';
import '../../features/schedule/presentation/screens/schedule_screen.dart';
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
    ],
  );
});
