/// Kumpulan path endpoint REST API Laravel (`/api/v1/...`).
///
/// Diisi bertahap seiring modul dikembangkan pada fase berikutnya.
/// Base URL diambil dari [AppEnv.apiBaseUrl], di sini hanya path relatif.
class ApiEndpoints {
  const ApiEndpoints._();

  // Auth
  static const String authExchangeToken = '/auth/exchange-token';
  static const String authMe = '/auth/me';
  static const String authLogout = '/auth/logout';

  // Beranda
  static const String home = '/home';

  // Jadwal & Kalender
  static const String schedules = '/schedules';

  // Warta
  static const String announcements = '/announcements';

  // Formulir Pelayanan
  static const String serviceForms = '/service-forms';

  // Permohonan Doa
  static const String prayerRequests = '/prayer-requests';

  // Donasi
  static const String donations = '/donations';
  static const String churchBankAccounts = '/church-bank-accounts';

  // Direktori Pelayan
  static const String directory = '/directory';

  // Komunitas
  static const String communities = '/communities';

  // Keuangan (grafik, read-only untuk jemaat)
  static const String financeSummary = '/finance/summary';

  // Media
  static const String sermons = '/media/sermons';
  static const String hymns = '/media/hymns';

  // Profil
  static const String profile = '/profile';

  // Search global
  static const String search = '/search';
}
