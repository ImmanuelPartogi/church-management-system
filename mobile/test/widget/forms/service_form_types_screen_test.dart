import 'package:church_management_mobile/features/forms/domain/entities/service_form_type.dart';
import 'package:church_management_mobile/features/forms/presentation/providers/service_forms_provider.dart';
import 'package:church_management_mobile/features/forms/presentation/screens/service_form_types_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createWidgetToTest(List<Override> overrides) {
    return ProviderScope(
      overrides: overrides,
      child: const MaterialApp(
        home: ServiceFormTypesScreen(),
      ),
    );
  }

  testWidgets('renders loading state initially', (tester) async {
    await tester.pumpWidget(
      createWidgetToTest([
        serviceFormTypesProvider.overrideWith((ref) async {
          await Future<List<ServiceFormType>>.delayed(
            const Duration(seconds: 2),
          );
          return [];
        }),
      ]),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders empty state when list is empty', (tester) async {
    await tester.pumpWidget(
      createWidgetToTest([
        serviceFormTypesProvider.overrideWith((ref) async => []),
      ]),
    );

    await tester.pumpAndSettle();

    expect(
      find.text('Belum ada jenis formulir pelayanan tersedia'),
      findsOneWidget,
    );
  });

  testWidgets('renders list of active service form types', (tester) async {
    final mockTypes = [
      const ServiceFormType(
        id: 1,
        name: 'Baptisan Kudus',
        slug: 'baptisan-kudus',
        description: 'Formulir pendaftaran baptisan',
        feeAmount: 0,
        active: true,
      ),
      const ServiceFormType(
        id: 2,
        name: 'Pernikahan',
        slug: 'pernikahan',
        description: 'Formulir pemberkatan nikah',
        feeAmount: 100000,
        active: true,
      ),
    ];

    await tester.pumpWidget(
      createWidgetToTest([
        serviceFormTypesProvider.overrideWith((ref) async => mockTypes),
      ]),
    );

    await tester.pumpAndSettle();

    expect(find.text('Baptisan Kudus'), findsOneWidget);
    expect(find.text('Pernikahan'), findsOneWidget);
    expect(find.text('Biaya: Gratis'), findsOneWidget);
    expect(find.text('Biaya: Rp 100.000'), findsOneWidget);
  });
}
