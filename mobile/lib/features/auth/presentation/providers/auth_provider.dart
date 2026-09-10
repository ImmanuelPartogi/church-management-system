import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';

import '../../../church/presentation/providers/tenant_provider.dart';

part 'auth_provider.freezed.dart';
part 'auth_provider.g.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    _checkInitialAuth();
    return const AuthState.initial();
  }

  Future<void> _checkInitialAuth() async {
    state = const AuthState.loading();
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.getCurrentUser();

    await result.fold(
      (failure) async => state = const AuthState.unauthenticated(),
      (user) async {
        await ref.read(tenantProvider.notifier).reconcileWithUser(user);
        state = AuthState.authenticated(user);
      },
    );
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = const AuthState.loading();
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.signInWithEmailAndPassword(email, password);

    await result.fold(
      (failure) async => state = AuthState.error(failure.message),
      (user) async {
        await ref.read(tenantProvider.notifier).reconcileWithUser(user);
        state = AuthState.authenticated(user);
      },
    );
  }

  Future<void> signInWithGoogle() async {
    state = const AuthState.loading();
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.signInWithGoogle();

    await result.fold(
      (failure) async => state = AuthState.error(failure.message),
      (user) async {
        await ref.read(tenantProvider.notifier).reconcileWithUser(user);
        state = AuthState.authenticated(user);
      },
    );
  }

  Future<void> logout() async {
    state = const AuthState.loading();
    final repository = ref.read(authRepositoryProvider);
    await repository.logout();
    state = const AuthState.unauthenticated();
  }

  void forceLogout() {
    state = const AuthState.unauthenticated();
  }
}
