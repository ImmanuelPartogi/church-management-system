import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  const ApiConstants._();

  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api/v1';

  static const String authFirebaseEndpoint = '/auth/firebase';
  static const String authMeEndpoint = '/auth/me';
  static const String authLogoutEndpoint = '/auth/logout';

  static const String dailyVerseEndpoint = '/daily-verse';
  static const String announcementsEndpoint = '/announcements';
  static const String worshipSchedulesEndpoint = '/worship-schedules';
  static const String worshipSchedulesCalendarEndpoint =
      '/worship-schedules/calendar';

  static const String wartasEndpoint = '/wartas';
  static String wartaDetailEndpoint(int id) => '/wartas/$id';
  static String wartaDownloadEndpoint(int id) => '/wartas/$id/download';

  static const String serviceFormTypesEndpoint = '/service-form-types';
  static String serviceFormTypeDetailEndpoint(int id) =>
      '/service-form-types/$id';
  static const String serviceFormApplicationsEndpoint =
      '/service-form-applications';
  static String serviceFormApplicationDetailEndpoint(int id) =>
      '/service-form-applications/$id';

  static const String churchBankAccountsEndpoint = '/church-bank-accounts';
  static const String donationConfirmEndpoint = '/donations/confirm';
  static const String myDonationsEndpoint = '/donations/my-donations';
  static String donationDetailEndpoint(int id) => '/donations/$id';

  static const String prayerRequestsEndpoint = '/prayer-requests';
  static String prayerRequestDetailEndpoint(int id) => '/prayer-requests/$id';

  static const String songbooksEndpoint = '/songbooks';
  static const String songsEndpoint = '/songs';
  static String songDetailEndpoint(int id) => '/songs/$id';

  static const String financialTransparencyEndpoint = '/finances/transparency';

  static const String membersEndpoint = '/members';
  static const String memberSearchEndpoint = '/members/search';
  static String memberDetailEndpoint(int id) => '/members/$id';

  static const String servantsEndpoint = '/servants';
  static String servantDetailEndpoint(int id) => '/servants/$id';

  static const String sermonsEndpoint = '/sermons';
  static String sermonDetailEndpoint(int id) => '/sermons/$id';
  static String sermonDownloadEndpoint(int id) => '/sermons/$id/download';
}
