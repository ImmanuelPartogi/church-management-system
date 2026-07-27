/// Path & nama route terpusat supaya navigasi (`context.goNamed(...)`)
/// tidak memakai string literal yang tersebar di seluruh screen.
class RoutePaths {
  const RoutePaths._();

  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Main shell (bottom nav)
  static const String home = '/home';
  static const String scheduleCalendar = '/schedule';
  static const String announcements = '/announcements';
  static const String profile = '/profile';

  // Fitur lain (diakses dari Beranda / shortcut)
  static const String serviceForms = '/service-forms';
  static const String serviceFormDetail = '/service-forms/:id';
  static const String prayerRequests = '/prayer-requests';
  static const String donations = '/donations';
  static const String donationHistory = '/donations/history';
  static const String directory = '/directory';
  static const String community = '/community';
  static const String finance = '/finance';
  static const String media = '/media';
  static const String hymnBook = '/media/hymns';
  static const String search = '/search';
}

class RouteNames {
  const RouteNames._();

  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgotPassword';
  static const String home = 'home';
  static const String scheduleCalendar = 'scheduleCalendar';
  static const String announcements = 'announcements';
  static const String profile = 'profile';
  static const String serviceForms = 'serviceForms';
  static const String serviceFormDetail = 'serviceFormDetail';
  static const String prayerRequests = 'prayerRequests';
  static const String donations = 'donations';
  static const String donationHistory = 'donationHistory';
  static const String directory = 'directory';
  static const String community = 'community';
  static const String finance = 'finance';
  static const String media = 'media';
  static const String hymnBook = 'hymnBook';
  static const String search = 'search';
}
