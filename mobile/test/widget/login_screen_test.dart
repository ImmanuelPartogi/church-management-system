import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'package:church_management_mobile/core/error/failures.dart';
import 'package:church_management_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:church_management_mobile/features/auth/domain/entities/user.dart';
import 'package:church_management_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:church_management_mobile/features/auth/presentation/screens/login_screen.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    return const Left(AuthFailure('Tidak ada sesi.'));
  }

  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword(
      String email, String password) async {
    if (email == 'user@church.org' && password == 'password123') {
      return const Right(
        User(
          id: 1,
          name: 'Jemaat Test',
          email: 'user@church.org',
          roles: ['member'],
        ),
      );
    }
    return const Left(AuthFailure('Email atau password salah.'));
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    return const Right(
      User(
        id: 2,
        name: 'Google User',
        email: 'google@church.org',
        roles: ['member'],
      ),
    );
  }

  @override
  Future<Either<Failure, User>> loginWithFirebaseToken(
      String firebaseIdToken) async {
    return const Right(
      User(
        id: 1,
        name: 'Jemaat Test',
        email: 'user@church.org',
        roles: ['member'],
      ),
    );
  }

  @override
  Future<Either<Failure, void>> logout() async {
    return const Right(null);
  }
}

void main() {
  group('LoginScreen Widget Tests', () {
    late FakeAuthRepository fakeAuthRepository;

    setUp(() {
      fakeAuthRepository = FakeAuthRepository();
    });

    Widget createWidgetUnderTest() {
      return ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      );
    }

    testWidgets('renders all UI components cleanly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify branding and title
      expect(find.text('Church Management System'), findsOneWidget);
      expect(find.text('Masuk ke Akun Jemaat Anda'), findsOneWidget);

      // Verify form text fields
      expect(find.text('Alamat Email'), findsOneWidget);
      expect(find.text('Kata Sandi'), findsOneWidget);

      // Verify buttons
      expect(find.text('Masuk'), findsOneWidget);
      expect(find.text('Masuk dengan Google'), findsOneWidget);
    });

    testWidgets('shows validation errors when fields are empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap login button without entering values
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      // Verify error validation texts
      expect(find.text('Email wajib diisi'), findsOneWidget);
      expect(find.text('Kata sandi wajib diisi'), findsOneWidget);
    });

    testWidgets('shows validation error for invalid email format',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField).at(0), 'invalidemail');
      await tester.enterText(find.byType(TextFormField).at(1), '123456');

      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      expect(find.text('Format email tidak valid'), findsOneWidget);
    });
  });
}
