import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:church_management_mobile/core/widgets/app_module_disabled_view.dart';

void main() {
  group('AppModuleDisabledView Widget Tests', () {
    testWidgets('renders polite disabled module UI components with custom module name',
        (tester) async {
      var backPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppModuleDisabledView(
              module: 'finances',
              message: 'Modul ini sedang dinonaktifkan oleh administrator gereja.',
              actionLabel: 'Kembali ke Beranda',
              onAction: () {
                backPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Title & Message
      expect(find.text('Fitur Dinonaktifkan'), findsOneWidget);
      expect(find.text('Modul ini sedang dinonaktifkan oleh administrator gereja.'), findsOneWidget);
      expect(find.text('Modul: finances'), findsOneWidget);
      expect(find.text('Kembali ke Beranda'), findsOneWidget);
      expect(find.byIcon(Icons.layers_clear_rounded), findsOneWidget);

      // Verify onBack callback
      await tester.tap(find.text('Kembali ke Beranda'));
      await tester.pump();

      expect(backPressed, isTrue);
    });
  });
}
