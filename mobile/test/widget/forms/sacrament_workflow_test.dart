import 'package:church_management_mobile/features/forms/domain/entities/service_form_application.dart';
import 'package:church_management_mobile/features/forms/domain/entities/service_form_type.dart';
import 'package:church_management_mobile/features/forms/presentation/providers/service_forms_provider.dart';
import 'package:church_management_mobile/features/forms/presentation/screens/service_form_application_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createWidgetToTest(int id, List<Override> overrides) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: ServiceFormApplicationDetailScreen(id: id),
      ),
    );
  }

  testWidgets('renders sacrament approval chain timeline for sacrament applications',
      (tester) async {
    const mockApp = ServiceFormApplication(
      id: 10,
      applicationNumber: 'APP-SACRAMENT-001',
      userId: 5,
      serviceFormType: ServiceFormType(
        id: 1,
        name: 'Baptisan Kudus',
        slug: 'baptis',
        feeAmount: 0,
        active: true,
      ),
      status: 'sector_verified',
      paymentStatus: 'paid',
      documents: [],
      createdAt: '2026-09-11T10:00:00.000000Z',
      updatedAt: '2026-09-11T10:00:00.000000Z',
    );

    await tester.pumpWidget(
      createWidgetToTest(10, [
        serviceFormApplicationDetailProvider(10)
            .overrideWith((ref) async => mockApp),
      ]),
    );

    await tester.pumpAndSettle();

    expect(find.text('APP-SACRAMENT-001'), findsOneWidget);
    expect(find.text('Terverifikasi Sintua Sektor'), findsOneWidget);
    expect(find.text('Alur Persetujuan Sakramen'), findsOneWidget);
    expect(find.text('Diajukan'), findsOneWidget);
    expect(find.text('Verifikasi Sektor'), findsOneWidget);
    expect(find.text('Persetujuan Pastoral'), findsOneWidget);
    expect(find.text('Pelaksanaan Sakramen'), findsOneWidget);
  });

  testWidgets('renders rejection reason when sacrament application is rejected',
      (tester) async {
    const mockApp = ServiceFormApplication(
      id: 11,
      applicationNumber: 'APP-SACRAMENT-002',
      userId: 5,
      serviceFormType: ServiceFormType(
        id: 2,
        name: 'Peneguhan Sidi',
        slug: 'sidi',
        feeAmount: 0,
        active: true,
      ),
      status: 'rejected',
      rejectionReason: 'Jemaat belum menyelesaikan katekisasi 12 sesi.',
      paymentStatus: 'unpaid',
      documents: [],
      createdAt: '2026-09-11T10:00:00.000000Z',
      updatedAt: '2026-09-11T10:00:00.000000Z',
    );

    await tester.pumpWidget(
      createWidgetToTest(11, [
        serviceFormApplicationDetailProvider(11)
            .overrideWith((ref) async => mockApp),
      ]),
    );

    await tester.pumpAndSettle();

    expect(find.text('APP-SACRAMENT-002'), findsOneWidget);
    expect(find.text('Ditolak'), findsOneWidget);
    expect(
      find.text('Jemaat belum menyelesaikan katekisasi 12 sesi.'),
      findsOneWidget,
    );
  });
}
