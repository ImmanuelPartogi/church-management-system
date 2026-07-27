import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/announcement/presentation/screens/announcement_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/community/presentation/screens/community_screen.dart';
import '../../features/directory/presentation/screens/directory_screen.dart';
import '../../features/donation/presentation/screens/donation_screen.dart';
import '../../features/finance/presentation/screens/finance_screen.dart';
import '../../features/forms/presentation/screens/service_forms_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/media/presentation/screens/media_screen.dart';
import '../../features/prayer_request/presentation/screens/prayer_request_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/schedule/presentation/screens/schedule_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import 'main_shell.dart';
import 'route_paths.dart';

/// Provider utama GoRouter. Redirect berbasis auth state (mis. belum
/// login -> paksa ke [RoutePaths.login]) akan ditambahkan di fase
/// implementasi modul Authentication, memakai `refreshListenable` yang
/// mendengarkan auth provider.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePaths.home,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // Shell dengan bottom navigation: Beranda, Jadwal, Warta, Profil.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.home,
                name: RouteNames.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.scheduleCalendar,
                name: RouteNames.scheduleCalendar,
                builder: (context, state) => const ScheduleScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.announcements,
                name: RouteNames.announcements,
                builder: (context, state) => const AnnouncementScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                name: RouteNames.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Fitur lain diakses sebagai halaman terpisah (dari shortcut Beranda).
      GoRoute(
        path: RoutePaths.serviceForms,
        name: RouteNames.serviceForms,
        builder: (context, state) => const ServiceFormsScreen(),
      ),
      GoRoute(
        path: RoutePaths.prayerRequests,
        name: RouteNames.prayerRequests,
        builder: (context, state) => const PrayerRequestScreen(),
      ),
      GoRoute(
        path: RoutePaths.donations,
        name: RouteNames.donations,
        builder: (context, state) => const DonationScreen(),
      ),
      GoRoute(
        path: RoutePaths.directory,
        name: RouteNames.directory,
        builder: (context, state) => const DirectoryScreen(),
      ),
      GoRoute(
        path: RoutePaths.community,
        name: RouteNames.community,
        builder: (context, state) => const CommunityScreen(),
      ),
      GoRoute(
        path: RoutePaths.finance,
        name: RouteNames.finance,
        builder: (context, state) => const FinanceScreen(),
      ),
      GoRoute(
        path: RoutePaths.media,
        name: RouteNames.media,
        builder: (context, state) => const MediaScreen(),
      ),
      GoRoute(
        path: RoutePaths.search,
        name: RouteNames.search,
        builder: (context, state) => const SearchScreen(),
      ),
    ],
  );
});
