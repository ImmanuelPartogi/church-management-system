import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:church_management_mobile/core/widgets/app_no_membership_view.dart';

void main() {
  group('AppNoMembershipView Widget Tests', () {
    testWidgets('renders inactive membership warning and triggers onLogout callback',
        (tester) async {
      var logoutPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppNoMembershipView(
              message: 'Akun Anda belum terdaftar sebagai anggota aktif di gereja manapun.',
              onLogout: () {
                logoutPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Title & Message
      expect(find.text('Belum Terhubung ke Gereja'), findsOneWidget);
      expect(
        find.text('Akun Anda belum terdaftar sebagai anggota aktif di gereja manapun.'),
        findsOneWidget,
      );
      expect(find.text('Keluar Akun'), findsOneWidget);
      expect(find.byIcon(Icons.person_off_outlined), findsOneWidget);

      // Verify onLogout callback
      await tester.tap(find.text('Keluar Akun'));
      await tester.pump();

      expect(logoutPressed, isTrue);
    });
  });
}
