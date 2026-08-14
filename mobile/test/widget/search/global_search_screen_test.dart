import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:church_management_mobile/features/search/presentation/screens/global_search_screen.dart';

void main() {
  testWidgets('renders search field, filter chips, and empty hint initially',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: GlobalSearchScreen(),
        ),
      ),
    );

    expect(find.text('Pencarian Lintas Modul'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Anggota'), findsOneWidget);
    expect(find.text('Pelayan'), findsOneWidget);
    expect(find.text('Khotbah'), findsOneWidget);
    expect(find.text('Ketik minimal 2 karakter untuk mencari'), findsOneWidget);
  });
}
