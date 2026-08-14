import 'package:church_management_mobile/core/error/failures.dart';
import 'package:church_management_mobile/features/media/data/repositories/sermon_repository_impl.dart';
import 'package:church_management_mobile/features/media/domain/entities/sermon.dart';
import 'package:church_management_mobile/features/media/domain/repositories/sermon_repository.dart';
import 'package:church_management_mobile/features/media/presentation/screens/sermons_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

class FakeSermonRepository implements SermonRepository {
  final List<Sermon> sermons;
  final String? errorMessage;

  FakeSermonRepository({
    this.sermons = const [],
    this.errorMessage,
  });

  @override
  Future<Either<Failure, List<Sermon>>> getSermons({
    String? search,
    int page = 1,
  }) async {
    if (errorMessage != null) {
      return Left(ServerFailure(errorMessage!));
    }
    return Right(sermons);
  }

  @override
  Future<Either<Failure, Sermon>> getSermonDetail(int id) async {
    if (errorMessage != null) {
      return Left(ServerFailure(errorMessage!));
    }
    return Right(
      sermons.firstWhere(
        (s) => s.id == id,
        orElse: () => const Sermon(
          id: 1,
          title: 'Kasih Allah yang Sempurna',
          preacherName: 'Pdt. Stiven Hutapea',
          downloadCount: 10,
          isPublished: true,
        ),
      ),
    );
  }

  @override
  Future<Either<Failure, int>> downloadSermon(int id) async {
    if (errorMessage != null) {
      return Left(ServerFailure(errorMessage!));
    }
    return const Right(11);
  }
}

void main() {
  final testSermons = [
    const Sermon(
      id: 1,
      title: 'Kasih Allah yang Sempurna',
      preacherName: 'Pdt. Stiven Hutapea',
      fileSize: 1048576,
      downloadCount: 15,
      publishedAt: '2026-08-10T10:00:00Z',
      isPublished: true,
    ),
  ];

  Widget createWidgetToTest(FakeSermonRepository repo) {
    return ProviderScope(
      overrides: [
        sermonRepositoryProvider.overrideWithValue(repo),
      ],
      child: const MaterialApp(
        home: SermonsScreen(),
      ),
    );
  }

  testWidgets('renders sermons search input and list cleanly', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final repo = FakeSermonRepository(sermons: testSermons);

    await tester.pumpWidget(createWidgetToTest(repo));
    await tester.pumpAndSettle();

    expect(find.text('Arsip Khotbah & Media'), findsOneWidget);
    expect(find.text('Kasih Allah yang Sempurna'), findsOneWidget);
    expect(find.text('Pdt. Stiven Hutapea'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
  });
}
