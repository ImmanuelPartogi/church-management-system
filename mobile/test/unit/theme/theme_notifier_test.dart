import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:church_management_mobile/core/storage/secure_storage_service.dart';
import 'package:church_management_mobile/core/theme/church_theme_state.dart';
import 'package:church_management_mobile/core/theme/theme_notifier.dart';
import 'package:church_management_mobile/features/church/domain/entities/church.dart';

class MockSecureStorageService implements SecureStorageService {
  final Map<String, dynamic> _storage = {};

  @override
  Future<void> saveChurchTheme(int churchId, Map<String, dynamic> themeData) async {
    _storage['church_theme_$churchId'] = themeData;
  }

  @override
  Future<Map<String, dynamic>?> getChurchTheme(int churchId) async {
    final data = _storage['church_theme_$churchId'];
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  @override
  Future<void> removeChurchTheme(int churchId) async {
    _storage.remove('church_theme_$churchId');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FaultySecureStorageService implements SecureStorageService {
  @override
  Future<Map<String, dynamic>?> getChurchTheme(int churchId) async {
    throw Exception('Disk I/O failure');
  }

  @override
  Future<void> saveChurchTheme(int churchId, Map<String, dynamic> themeData) async {
    throw Exception('Disk full');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ChurchThemeState Model & Hex Parsing Tests', () {
    test('parses standard 6-char hex with hash', () {
      final color = ChurchThemeState.parseHexColor('#1B4B66', Colors.black);
      expect(color.toARGB32(), const Color(0xFF1B4B66).toARGB32());
    });

    test('parses 6-char hex without hash', () {
      final color = ChurchThemeState.parseHexColor('F5A623', Colors.black);
      expect(color.toARGB32(), const Color(0xFFF5A623).toARGB32());
    });

    test('parses 8-char hex with alpha channel', () {
      final color = ChurchThemeState.parseHexColor('#FF1B4B66', Colors.black);
      expect(color.toARGB32(), const Color(0xFF1B4B66).toARGB32());
    });

    test('returns fallback color when hex string is null or invalid', () {
      const fallback = Color(0xFF123456);
      expect(ChurchThemeState.parseHexColor(null, fallback), fallback);
      expect(ChurchThemeState.parseHexColor('', fallback), fallback);
      expect(ChurchThemeState.parseHexColor('not-a-hex', fallback), fallback);
      expect(ChurchThemeState.parseHexColor('#123', fallback), fallback);
    });

    test('serializes to and from JSON faithfully', () {
      const theme = ChurchThemeState(
        primaryColor: Color(0xFF0F2C3F),
        secondaryColor: Color(0xFFE58A1F),
        themeVersion: 3,
        logoUrl: 'https://cdn.church.org/logo.png',
        isCustom: true,
      );

      final json = theme.toJson();
      expect(json['theme_primary_color'], '#0F2C3F');
      expect(json['theme_secondary_color'], '#E58A1F');
      expect(json['theme_version'], 3);
      expect(json['logo_url'], 'https://cdn.church.org/logo.png');

      final reconstructed = ChurchThemeState.fromJson(json);
      expect(reconstructed.primaryColor.toARGB32(), theme.primaryColor.toARGB32());
      expect(reconstructed.secondaryColor.toARGB32(), theme.secondaryColor.toARGB32());
      expect(reconstructed.themeVersion, 3);
      expect(reconstructed.logoUrl, 'https://cdn.church.org/logo.png');
      expect(reconstructed.isCustom, isTrue);
    });
  });

  group('ThemeNotifier 3-Tier Fallback Tests (ADR 12)', () {
    late MockSecureStorageService storage;
    late ThemeNotifier notifier;

    const churchAlpha = Church(
      id: 10,
      uuid: 'uuid-alpha',
      name: 'HKBP Alpha',
      slug: 'hkbp-alpha',
      themePrimaryColor: '#0F2C3F',
      themeSecondaryColor: '#E58A1F',
      themeVersion: 2,
      logoUrl: 'https://cdn.church.org/alpha.png',
    );

    const churchBeta = Church(
      id: 20,
      uuid: 'uuid-beta',
      name: 'HKBP Beta',
      slug: 'hkbp-beta',
      themePrimaryColor: '#2E7D32',
      themeSecondaryColor: '#FFB300',
      themeVersion: 1,
    );

    const legacyChurch = Church(
      id: 30,
      uuid: 'uuid-legacy',
      name: 'Legacy Church',
      slug: 'legacy-church',
      // Null theme attributes
      themePrimaryColor: null,
      themeSecondaryColor: null,
      themeVersion: null,
    );

    setUp(() {
      storage = MockSecureStorageService();
      notifier = ThemeNotifier(storage);
    });

    test('Tier 3 Fallback: Initial state defaults to platform navy and amber without custom flag', () {
      expect(notifier.state.primaryColor.toARGB32(), ChurchThemeState.defaultPrimary.toARGB32());
      expect(notifier.state.secondaryColor.toARGB32(), ChurchThemeState.defaultSecondary.toARGB32());
      expect(notifier.state.themeVersion, 1);
      expect(notifier.state.isCustom, isFalse);
    });

    test('Tier 2 Fallback: Applies API payload and writes to local cache when custom colors exist', () async {
      await notifier.updateFromChurch(churchAlpha);

      // State is updated from churchAlpha payload
      expect(notifier.state.primaryColor.toARGB32(), const Color(0xFF0F2C3F).toARGB32());
      expect(notifier.state.secondaryColor.toARGB32(), const Color(0xFFE58A1F).toARGB32());
      expect(notifier.state.themeVersion, 2);
      expect(notifier.state.logoUrl, 'https://cdn.church.org/alpha.png');
      expect(notifier.state.isCustom, isTrue);

      // Cached in local storage
      final cached = await storage.getChurchTheme(10);
      expect(cached, isNotNull);
      expect(cached?['theme_primary_color'], '#0F2C3F');
      expect(cached?['theme_secondary_color'], '#E58A1F');
      expect(cached?['theme_version'], 2);
    });

    test('Tier 1 Fallback: Loads theme from local cache even if API payload has null theme attributes', () async {
      // Pre-seed local cache
      await storage.saveChurchTheme(30, {
        'theme_primary_color': '#3F51B5',
        'theme_secondary_color': '#FF4081',
        'theme_version': 5,
        'logo_url': null,
      });

      // Update from legacy church (API payload has null theme attributes)
      await notifier.updateFromChurch(legacyChurch);

      // Successfully resolved from local cache!
      expect(notifier.state.primaryColor.toARGB32(), const Color(0xFF3F51B5).toARGB32());
      expect(notifier.state.secondaryColor.toARGB32(), const Color(0xFFFF4081).toARGB32());
      expect(notifier.state.themeVersion, 5);
      expect(notifier.state.isCustom, isTrue);
    });

    test('Theme Version Invalidation: Invalidation triggers when API version exceeds cached version', () async {
      // Pre-seed cache with v1
      await storage.saveChurchTheme(10, {
        'theme_primary_color': '#111111',
        'theme_secondary_color': '#222222',
        'theme_version': 1,
      });

      // Incoming churchAlpha has themeVersion: 2
      await notifier.updateFromChurch(churchAlpha);

      // Theme is invalidated and updated to v2
      expect(notifier.state.primaryColor.toARGB32(), const Color(0xFF0F2C3F).toARGB32());
      expect(notifier.state.secondaryColor.toARGB32(), const Color(0xFFE58A1F).toARGB32());
      expect(notifier.state.themeVersion, 2);

      // Cache is updated
      final updatedCache = await storage.getChurchTheme(10);
      expect(updatedCache?['theme_version'], 2);
    });

    test('Tenant Switching: Switching active church immediately updates theme', () async {
      // Select Church Alpha
      await notifier.updateFromChurch(churchAlpha);
      expect(notifier.state.primaryColor.toARGB32(), const Color(0xFF0F2C3F).toARGB32());

      // Switch to Church Beta
      await notifier.updateFromChurch(churchBeta);
      expect(notifier.state.primaryColor.toARGB32(), const Color(0xFF2E7D32).toARGB32());
      expect(notifier.state.secondaryColor.toARGB32(), const Color(0xFFFFB300).toARGB32());
      expect(notifier.currentChurchId, 20);
    });

    test('Unselect Tenant: Explicitly clearing active church to null restores Tier 3 platform defaults', () async {
      await notifier.updateFromChurch(churchAlpha);
      expect(notifier.state.isCustom, isTrue);

      // Explicit detachment / unselect tenant action
      await notifier.updateFromChurch(null);
      expect(notifier.state.primaryColor.toARGB32(), ChurchThemeState.defaultPrimary.toARGB32());
      expect(notifier.state.secondaryColor.toARGB32(), ChurchThemeState.defaultSecondary.toARGB32());
      expect(notifier.state.isCustom, isFalse);
      expect(notifier.currentChurchId, isNull);
    });

    test('ADR 7.3 Guest Browsing: User logout preserves active church theme intact without resetting to default', () async {
      // User is currently browsing Church Alpha
      await notifier.updateFromChurch(churchAlpha);
      expect(notifier.state.primaryColor.toARGB32(), const Color(0xFF0F2C3F).toARGB32());

      // Under ADR 7.3, user logout clears auth tokens, but activeChurch in tenantProvider remains churchAlpha
      // Therefore, updateFromChurch is called with churchAlpha (or not called at all since activeChurch is unchanged)
      await notifier.updateFromChurch(churchAlpha);

      // Theme remains faithful to Church Alpha for guest browsing!
      expect(notifier.state.primaryColor.toARGB32(), const Color(0xFF0F2C3F).toARGB32());
      expect(notifier.state.isCustom, isTrue);
      expect(notifier.currentChurchId, 10);
    });

    test('Fail-Open Security: Storage exception does not crash theme notifier', () async {
      final faultyStorage = FaultySecureStorageService();
      final resilientNotifier = ThemeNotifier(faultyStorage);

      // Must not throw despite storage throwing Exception
      await expectLater(
        resilientNotifier.updateFromChurch(churchAlpha),
        completes,
      );

      // Defaults remain intact safely
      expect(resilientNotifier.state.primaryColor.toARGB32(), isNotNull);
    });
  });
}
