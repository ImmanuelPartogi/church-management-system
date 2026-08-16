import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'package:church_management_mobile/core/error/failures.dart';
import 'package:church_management_mobile/features/auth/domain/entities/user.dart';
import 'package:church_management_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:church_management_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:church_management_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:church_management_mobile/features/profile/presentation/providers/profile_provider.dart';
import 'package:church_management_mobile/features/profile/presentation/screens/profile_screen.dart';

class FakeAuthNotifier extends AuthNotifier {
  @override
  AuthState build() {
    return const AuthState.authenticated(
      User(
        id: 1,
        email: 'budi@example.com',
        name: 'Budi Jemaat',
        roles: ['member'],
      ),
    );
  }

  @override
  Future<void> logout() async {
    state = const AuthState.unauthenticated();
  }

  @override
  Future<void> forceLogout() async {
    state = const AuthState.unauthenticated();
  }
}

class FakeProfileRepository implements ProfileRepository {
  final UserProfile profile;

  FakeProfileRepository(this.profile);

  @override
  Future<Either<Failure, UserProfile>> getProfile() async => Right(profile);

  @override
  Future<Either<Failure, UserProfile>> updateProfile({
    required String name,
    String? phone,
    String? address,
  }) async =>
      Right(
        UserProfile(
          id: profile.id,
          name: name,
          email: profile.email,
          phone: phone,
          address: address,
          roles: profile.roles,
          member: profile.member,
        ),
      );

  @override
  Future<Either<Failure, void>> deleteAccount() async => const Right(null);
}

void main() {
  testWidgets(
      'renders profile user header, info card, edit button, and delete account action',
      (tester) async {
    const profile = UserProfile(
      id: 1,
      name: 'Budi Jemaat',
      email: 'budi@example.com',
      phone: '081234567890',
      address: 'Jl. Gereja No. 1',
      roles: ['member'],
    );

    final fakeRepo = FakeProfileRepository(profile);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(() => FakeAuthNotifier()),
          profileRepositoryProvider.overrideWithValue(fakeRepo),
          userProfileProvider.overrideWith((ref) async => profile),
        ],
        child: const MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Profil Saya'), findsOneWidget);
    expect(find.text('Budi Jemaat'), findsNWidgets(2));
    expect(find.text('budi@example.com'), findsNWidgets(2));
    expect(find.text('Informasi Akun'), findsOneWidget);
    expect(find.text('Edit Profil'), findsOneWidget);
    expect(find.text('Keluar / Logout'), findsOneWidget);
    expect(find.text('Hapus Akun Saya'), findsOneWidget);
  });
}
