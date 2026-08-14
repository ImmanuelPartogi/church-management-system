import 'package:church_management_mobile/features/prayer_requests/presentation/screens/create_prayer_request_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createWidgetToTest() {
    return const ProviderScope(
      child: MaterialApp(
        home: CreatePrayerRequestScreen(),
      ),
    );
  }

  testWidgets('renders form fields and privacy toggle explanation cleanly',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createWidgetToTest());
    await tester.pumpAndSettle();

    expect(find.text('Buat Permohonan Doa'), findsOneWidget);
    expect(find.text('Judul Pokok Doa *'), findsOneWidget);
    expect(find.text('Isi Permohonan Doa *'), findsOneWidget);
    expect(find.text('Sifat Rahasia (Privat)'), findsOneWidget);
    expect(
      find.text(
        'Permohonan doa bersifat rahasia (Privat) dan hanya dapat dibaca oleh Pendeta & Majelis Gereja.',
      ),
      findsOneWidget,
    );
    expect(find.text('Kirim Permohonan Doa'), findsOneWidget);
  });

  testWidgets('shows validation errors when required fields are empty',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createWidgetToTest());
    await tester.pumpAndSettle();

    final submitButton =
        find.widgetWithText(ElevatedButton, 'Kirim Permohonan Doa');
    await tester.tap(submitButton, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Judul pokok doa wajib diisi'), findsOneWidget);
    expect(find.text('Isi permohonan doa wajib diisi'), findsOneWidget);
  });
}
