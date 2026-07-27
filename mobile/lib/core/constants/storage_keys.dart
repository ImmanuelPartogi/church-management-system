/// Kunci-kunci yang dipakai untuk penyimpanan lokal
/// (secure storage / shared preferences).
class StorageKeys {
  const StorageKeys._();

  static const String sanctumToken = 'sanctum_token';
  static const String firebaseIdToken = 'firebase_id_token';
  static const String fcmToken = 'fcm_token';
  static const String userProfile = 'user_profile';
  static const String hasOnboarded = 'has_onboarded';
}
