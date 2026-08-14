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
}
