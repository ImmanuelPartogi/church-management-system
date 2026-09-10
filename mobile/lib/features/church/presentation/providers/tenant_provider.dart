import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../auth/domain/entities/user.dart';
import '../../data/models/church_model.dart';
import '../../data/repositories/church_repository_impl.dart';
import '../../domain/entities/church.dart';
import '../../domain/repositories/church_repository.dart';

class TenantState {
  final Church? activeChurch;
  final bool isLoading;
  final String? errorMessage;
  final bool promptMultiMembershipSelection;

  const TenantState({
    this.activeChurch,
    this.isLoading = false,
    this.errorMessage,
    this.promptMultiMembershipSelection = false,
  });

  TenantState copyWith({
    Church? activeChurch,
    bool? isLoading,
    String? errorMessage,
    bool? promptMultiMembershipSelection,
  }) {
    return TenantState(
      activeChurch: activeChurch ?? this.activeChurch,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      promptMultiMembershipSelection:
          promptMultiMembershipSelection ?? this.promptMultiMembershipSelection,
    );
  }
}

final tenantProvider = StateNotifierProvider<TenantNotifier, TenantState>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  final repo = ref.watch(churchRepositoryProvider);
  return TenantNotifier(storage, repo);
});

final activeChurchProvider = Provider<Church?>((ref) {
  return ref.watch(tenantProvider).activeChurch;
});

class TenantNotifier extends StateNotifier<TenantState> {
  final SecureStorageService _storage;
  final ChurchRepository _repository;

  TenantNotifier(this._storage, this._repository)
      : super(const TenantState()) {
    init();
  }

  Future<void> init() async {
    state = state.copyWith(isLoading: true);
    try {
      final savedData = await _storage.getActiveChurch();
      if (!mounted) return;
      if (savedData != null) {
        final church = ChurchModel.fromJson(savedData).toEntity();
        state = state.copyWith(activeChurch: church, isLoading: false);
        return;
      }

      // If no saved church, fetch from public API and select default
      final result = await _repository.getChurches();
      if (!mounted) return;
      await result.fold(
        (Failure failure) async {
          if (!mounted) return;
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (List<Church> churches) async {
          if (!mounted) return;
          if (churches.isNotEmpty) {
            // Find default church slug or pick first
            final defaultChurch = churches.firstWhere(
              (c) => c.slug == 'default',
              orElse: () => churches.first,
            );
            await selectChurch(defaultChurch);
          } else {
            if (!mounted) return;
            state = state.copyWith(isLoading: false);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, errorMessage: e.toString());
      }
    }
  }

  Future<void> selectChurch(Church church) async {
    final model = ChurchModel.fromEntity(church);
    await _storage.saveActiveChurch(model.toJson());
    if (!mounted) return;
    state = state.copyWith(
      activeChurch: church,
      isLoading: false,
      errorMessage: null,
      promptMultiMembershipSelection: false,
    );
  }

  Future<void> clearChurch() async {
    await _storage.removeActiveChurch();
    if (!mounted) return;
    state = state.copyWith(activeChurch: null);
  }

  Future<Church?>? _inFlightReconcileFuture;

  /// Reconciles local tenant context when a user authenticates.
  /// Strictly enforces the ADR 7.4 matrix:
  /// 1. Super Admin -> Keep selection intact.
  /// 2. Active church is in user's memberships -> Keep selection intact.
  /// 3. Mismatch + 1 membership -> Auto-switch cleanly.
  /// 4. Mismatch + >= 2 memberships -> Fallback to primary membership deterministically
  ///    and trigger promptMultiMembershipSelection flag for UI dialog.
  ///
  /// In-flight calls are deduplicated to avoid duplicate disk I/O under parallel requests.
  Future<Church?> reconcileWithUser(User user) async {
    if (_inFlightReconcileFuture != null) {
      return _inFlightReconcileFuture!;
    }

    final future = _performReconcileWithUser(user);
    _inFlightReconcileFuture = future;
    try {
      return await future;
    } finally {
      _inFlightReconcileFuture = null;
    }
  }

  Future<Church?> _performReconcileWithUser(User user) async {
    if (user.isAdmin) {
      return state.activeChurch;
    }

    if (user.memberships.isEmpty) {
      return state.activeChurch;
    }

    final current = state.activeChurch;
    final isMemberOfCurrent = current != null &&
        user.memberships.any(
          (m) =>
              m.churchId == current.id ||
              m.churchSlug == current.slug ||
              (m.churchUuid != null && m.churchUuid == current.uuid),
        );

    if (isMemberOfCurrent) {
      // Local selection matches one of user's legitimate memberships!
      return current;
    }

    // Mismatch detected!
    if (user.memberships.length == 1) {
      // Case 3: Exactly 1 membership -> Auto-switch
      final m = user.memberships.first;
      final target = Church(
        id: m.churchId,
        uuid: m.churchUuid ?? '',
        name: m.churchName,
        slug: m.churchSlug,
      );
      await selectChurch(target);
      return target;
    } else {
      // Case 4: >= 2 memberships -> Set deterministic primary and trigger selection prompt
      final m = user.memberships.first;
      final target = Church(
        id: m.churchId,
        uuid: m.churchUuid ?? '',
        name: m.churchName,
        slug: m.churchSlug,
      );
      await selectChurch(target);
      state = state.copyWith(promptMultiMembershipSelection: true);
      return target;
    }
  }

  void dismissMultiMembershipPrompt() {
    if (state.promptMultiMembershipSelection) {
      state = state.copyWith(promptMultiMembershipSelection: false);
    }
  }
}
