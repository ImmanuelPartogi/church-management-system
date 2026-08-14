import 'package:church_management_mobile/core/error/failures.dart';
import 'package:church_management_mobile/features/prayer_requests/data/repositories/prayer_request_repository_impl.dart';
import 'package:church_management_mobile/features/prayer_requests/domain/entities/prayer_request.dart';
import 'package:church_management_mobile/features/prayer_requests/domain/repositories/prayer_request_repository.dart';
import 'package:church_management_mobile/features/prayer_requests/presentation/screens/create_prayer_request_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

class FakePrayerRequestRepository implements PrayerRequestRepository {
  @override
  Future<Either<Failure, List<PrayerRequest>>> getMyPrayerRequests(
      {int page = 1}) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, PrayerRequest>> getPrayerRequestDetail(int id) async {
    return const Left(ServerFailure('Not found'));
  }

  @override
  Future<Either<Failure, PrayerRequest>> submitPrayerRequest({
    required String title,
    required String content,
    String? category,
    bool isPrivate = true,
  }) async {
    return Right(
      PrayerRequest(
        id: 1,
        userId: 2,
        title: title,
        content: content,
        category: category,
        isPrivate: isPrivate,
        status: 'submitted',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
    );
  }
}

void main() {
  Widget createWidgetToTest() {
    return ProviderScope(
      overrides: [
        prayerRequestRepositoryProvider
            .overrideWithValue(FakePrayerRequestRepository()),
      ],
      child: const MaterialApp(
        home: CreatePrayerRequestScreen(),
      ),
    );
  }

  testWidgets('renders form fields and privacy toggle explanation cleanly',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

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
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(createWidgetToTest());
    await tester.pumpAndSettle();

    final submitButton = find.text('Kirim Permohonan Doa');
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.text('Judul pokok doa wajib diisi'), findsOneWidget);
    expect(find.text('Isi permohonan doa wajib diisi'), findsOneWidget);
  });
}
