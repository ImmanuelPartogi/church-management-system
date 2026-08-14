import 'package:church_management_mobile/core/error/failures.dart';
import 'package:church_management_mobile/features/community/data/repositories/servant_repository_impl.dart';
import 'package:church_management_mobile/features/community/domain/entities/church_servant.dart';
import 'package:church_management_mobile/features/community/domain/repositories/servant_repository.dart';
import 'package:church_management_mobile/features/community/presentation/screens/servants_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

class FakeServantRepository implements ServantRepository {
  final List<ChurchServant> servants;
  final String? errorMessage;

  FakeServantRepository({
    this.servants = const [],
    this.errorMessage,
  });

  @override
  Future<Either<Failure, List<ChurchServant>>> getServants({
    String? search,
    String? role,
    int? sectorId,
    int page = 1,
  }) async {
    if (errorMessage != null) {
      return Left(ServerFailure(errorMessage!));
    }
    return Right(servants);
  }

  @override
  Future<Either<Failure, ChurchServant>> getServantDetail(int id) async {
    if (errorMessage != null) {
      return Left(ServerFailure(errorMessage!));
    }
    return Right(
      servants.firstWhere(
        (s) => s.id == id,
        orElse: () => const ChurchServant(
          id: 1,
          name: 'Pdt. Stiven Hutapea',
          role: 'pdt_resort',
          roleLabel: 'Pendeta Resort',
          active: true,
        ),
      ),
    );
  }
}

void main() {
  final testServants = [
    const ChurchServant(
      id: 1,
      name: 'Pdt. Stiven Hutapea',
      role: 'pdt_resort',
      roleLabel: 'Pendeta Resort',
      maskedPhone: '0812****7890',
      active: true,
    ),
    const ChurchServant(
      id: 2,
      name: 'St. Maria Simanjuntak',
      role: 'sintua',
      roleLabel: 'Sintua',
      maskedPhone: '0898****4321',
      active: true,
    ),
  ];

  Widget createWidgetToTest(FakeServantRepository repo) {
    return ProviderScope(
      overrides: [
        servantRepositoryProvider.overrideWithValue(repo),
      ],
      child: const MaterialApp(
        home: ServantsScreen(),
      ),
    );
  }

  testWidgets('renders servants search input, filter chips, and list cleanly',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final repo = FakeServantRepository(servants: testServants);

    await tester.pumpWidget(createWidgetToTest(repo));
    await tester.pumpAndSettle();

    expect(find.text('Direktori Pelayan Gereja'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Pendeta'), findsOneWidget);
    expect(find.text('Pdt. Stiven Hutapea'), findsOneWidget);
    expect(find.text('Pendeta Resort'), findsOneWidget);
    expect(find.text('St. Maria Simanjuntak'), findsOneWidget);
  });
}
