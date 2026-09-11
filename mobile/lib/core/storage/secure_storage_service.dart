import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return const SecureStorageService(FlutterSecureStorage());
});

class SecureStorageService {
  final FlutterSecureStorage _storage;

  const SecureStorageService(this._storage);

  static const String _tokenKey = 'sanctum_token';
  static const String _userKey = 'user_data';
  static const String _activeChurchKey = 'active_church_data';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> removeToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _storage.write(key: _userKey, value: jsonEncode(userData));
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> removeUserData() async {
    await _storage.delete(key: _userKey);
  }

  Future<void> saveActiveChurch(Map<String, dynamic> churchData) async {
    await _storage.write(key: _activeChurchKey, value: jsonEncode(churchData));
  }

  Future<Map<String, dynamic>?> getActiveChurch() async {
    final raw = await _storage.read(key: _activeChurchKey);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static const String _themePrefix = 'church_theme_';

  Future<void> saveChurchTheme(int churchId, Map<String, dynamic> themeData) async {
    await _storage.write(key: '$_themePrefix$churchId', value: jsonEncode(themeData));
  }

  Future<Map<String, dynamic>?> getChurchTheme(int churchId) async {
    final raw = await _storage.read(key: '$_themePrefix$churchId');
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> removeChurchTheme(int churchId) async {
    await _storage.delete(key: '$_themePrefix$churchId');
  }

  Future<void> removeActiveChurch() async {
    await _storage.delete(key: _activeChurchKey);
  }

  Future<void> clearAll() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }
}
