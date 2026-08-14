import 'package:church_management_mobile/features/forms/domain/entities/service_form_application.dart';
import 'package:church_management_mobile/features/forms/domain/entities/service_form_type.dart';
import 'package:church_management_mobile/features/forms/presentation/providers/service_forms_provider.dart';
import 'package:church_management_mobile/features/forms/presentation/screens/service_form_applications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createWidgetToTest(List<Override> overrides) {
    return ProviderScope(
      overrides: overrides,
      child: const MaterialApp(
        home: ServiceFormApplicationsScreen(),
      ),
    );
  }

  testWidgets('renders empty state when applications history is empty',
      (tester) async {
    await tester.pumpWidget(
      createWidgetToTest([
        serviceFormApplicationsProvider.overrideWith((ref) async => []),
      ]),
    );

    await tester.pumpAndSettle();

    expect(
      find.text('Belum ada riwayat permohonan pelayanan'),
      findsOneWidget,
    );
  });

  testWidgets('renders application history list with status badges',
      (tester) async {
    final mockApps = [
      const ServiceFormApplication(
        id: 1,
        applicationNumber: 'APP-20260814-001',
        userId: 2,
        serviceFormType: ServiceFormType(
          id: 1,
          name: 'Baptisan Kudus',
          slug: 'baptisan-kudus',
          feeAmount: 0,
          active: true,
        ),
        status: 'pending',
        paymentStatus: 'unpaid',
        documents: [],
        createdAt: '2026-08-14T10:00:00.000000Z',
        updatedAt: '2026-08-14T10:00:00.000000Z',
      ),
      const ServiceFormApplication(
        id: 2,
        applicationNumber: 'APP-20260814-002',
        userId: 2,
        serviceFormType: ServiceFormType(
          id: 2,
          name: 'Sidi',
          slug: 'sidi',
          feeAmount: 0,
          active: true,
        ),
        status: 'approved',
        paymentStatus: 'waived',
        documents: [],
        createdAt: '2026-08-14T11:00:00.000000Z',
        updatedAt: '2026-08-14T11:00:00.000000Z',
      ),
    ];

    await tester.pumpWidget(
      createWidgetToTest([
        serviceFormApplicationsProvider.overrideWith((ref) async => mockApps),
      ]),
    );

    await tester.pumpAndSettle();

    expect(find.text('APP-20260814-001'), findsOneWidget);
    expect(find.text('APP-20260814-002'), findsOneWidget);
    expect(find.text('Baptisan Kudus'), findsOneWidget);
    expect(find.text('Sidi'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Disetujui'), findsOneWidget);
  });
}
