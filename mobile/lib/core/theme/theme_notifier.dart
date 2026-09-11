import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/church/domain/entities/church.dart';
import '../../features/church/presentation/providers/tenant_provider.dart';
import '../storage/secure_storage_service.dart';
import 'church_theme_state.dart';

final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, ChurchThemeState>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  final notifier = ThemeNotifier(storage);

  // Reactively synchronize theme whenever activeChurch changes (tenant switch or login reconciliation)
  ref.listen<TenantState>(tenantProvider, (previous, next) {
    final prevChurch = previous?.activeChurch;
    final nextChurch = next.activeChurch;

    if (prevChurch?.id != nextChurch?.id ||
        prevChurch?.themeVersion != nextChurch?.themeVersion ||
        prevChurch?.themePrimaryColor != nextChurch?.themePrimaryColor ||
        prevChurch?.themeSecondaryColor != nextChurch?.themeSecondaryColor ||
        prevChurch?.logoUrl != nextChurch?.logoUrl) {
      notifier.updateFromChurch(nextChurch);
    }
  });

  // Initial check on provider creation
  final initialChurch = ref.read(tenantProvider).activeChurch;
  if (initialChurch != null) {
    notifier.updateFromChurch(initialChurch);
  }

  return notifier;
});

/// Riverpod StateNotifier managing dynamic church theme with 3-tier fallback architecture:
/// Tier 1: Local Cache (SecureStorage / persistent cache)
/// Tier 2: API Payload (with theme_version invalidation check)
/// Tier 3: Hardcoded Platform Defaults (#1B4B66 and #F5A623)
class ThemeNotifier extends StateNotifier<ChurchThemeState> {
  final SecureStorageService _storage;
  int? _currentChurchId;

  ThemeNotifier(this._storage) : super(const ChurchThemeState());

  int? get currentChurchId => _currentChurchId;

  /// Synchronizes theme from an active Church instance adhering to 3-tier fallback.
  Future<void> updateFromChurch(Church? church) async {
    if (church == null) {
      _currentChurchId = null;
      state = const ChurchThemeState();
      return;
    }

    final isNewTenant = _currentChurchId != church.id;
    _currentChurchId = church.id;

    try {
      // Tier 1: Local Cache Check
      final cachedData = await _storage.getChurchTheme(church.id);
      int cachedVersion = 0;
      if (cachedData != null) {
        final cachedTheme = ChurchThemeState.fromJson(cachedData);
        state = cachedTheme;
        cachedVersion = cachedTheme.themeVersion;
      }

      // Tier 2: API Payload with theme_version invalidation
      if (church.themePrimaryColor != null && church.themeSecondaryColor != null) {
        final apiVersion = church.themeVersion ?? 1;

        // Invalidate if tenant switched, or no local cache exists, or API version is newer/equal
        if (isNewTenant || cachedData == null || apiVersion >= cachedVersion) {
          final updatedTheme = ChurchThemeState(
            primaryColor: ChurchThemeState.parseHexColor(
              church.themePrimaryColor,
              ChurchThemeState.defaultPrimary,
            ),
            secondaryColor: ChurchThemeState.parseHexColor(
              church.themeSecondaryColor,
              ChurchThemeState.defaultSecondary,
            ),
            themeVersion: apiVersion,
            logoUrl: church.logoUrl,
            isCustom: true,
          );

          state = updatedTheme;

          // Asynchronously persist updated theme to local cache
          await _storage.saveChurchTheme(church.id, updatedTheme.toJson());
          return;
        }
      }

      // If local cache was empty and API payload had no theme attributes, fall back to Tier 3
      if (cachedData == null) {
        state = const ChurchThemeState();
      }
    } catch (_) {
      // Fail-open security principle: Never crash theme resolution; fall back safely
      if (!state.isCustom) {
        state = const ChurchThemeState();
      }
    }
  }

  /// Manually set or override theme (useful for previewing or testing)
  Future<void> setTheme(ChurchThemeState newTheme, {int? churchId}) async {
    state = newTheme;
    final targetId = churchId ?? _currentChurchId;
    if (targetId != null) {
      await _storage.saveChurchTheme(targetId, newTheme.toJson());
    }
  }

  /// Resets theme to hardcoded Tier 3 defaults
  void resetToDefaults() {
    _currentChurchId = null;
    state = const ChurchThemeState();
  }
}
