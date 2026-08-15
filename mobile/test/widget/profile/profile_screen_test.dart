import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:church_management_mobile/features/auth/domain/entities/user.dart';
import 'package:church_management_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:church_management_mobile/features/profile/domain/entities/user_profile.dart';
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

void main() {
  testWidgets('renders profile user header, info card, edit button, and delete account action', (tester) async {
    const profile = UserProfile(
      id: 1,
      name: 'Budi Jemaat',
      email: 'budi@example.com',
      phone: '081234567890',
      address: 'Jl. Gereja No. 1',
      roles: ['member'],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(() => FakeAuthNotifier()),
          userProfileProvider.overrideWith((ref) => Future.value(profile)),
        ],
        child: const MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Profil Saya'), findsOneWidget);
    expect(find.text('Budi Jemaat'), findsNWidgets(2));
    expect(find.text('budi@example.com'), findsOneWidget);
    expect(find.text('Informasi Akun'), findsOneWidget);
    expect(find.text('Edit Profil'), findsOneWidget);
    expect(find.text('Keluar / Logout'), findsOneWidget);
    expect(find.text('Hapus Akun Saya'), findsOneWidget);
  });
}
