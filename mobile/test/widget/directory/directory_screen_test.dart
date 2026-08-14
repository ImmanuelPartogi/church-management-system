import 'package:church_management_mobile/core/error/failures.dart';
import 'package:church_management_mobile/features/directory/data/repositories/member_repository_impl.dart';
import 'package:church_management_mobile/features/directory/domain/entities/member_detail.dart';
import 'package:church_management_mobile/features/directory/domain/entities/member_directory_item.dart';
import 'package:church_management_mobile/features/directory/domain/repositories/member_repository.dart';
import 'package:church_management_mobile/features/directory/presentation/screens/directory_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

class FakeMemberRepository implements MemberRepository {
  final List<MemberDirectoryItem> members;
  final MemberDetail? detail;
  final String? errorMessage;

  FakeMemberRepository({
    this.members = const [],
    this.detail,
    this.errorMessage,
  });

  @override
  Future<Either<Failure, List<MemberDirectoryItem>>> searchMembers({
    String? query,
    int page = 1,
  }) async {
    if (errorMessage != null) {
      return Left(ServerFailure(errorMessage!));
    }
    var filtered = members;
    if (query != null && query.isNotEmpty) {
      filtered = filtered
          .where(
            (m) =>
                m.fullName.toLowerCase().contains(query.toLowerCase()) ||
                (m.membershipNumber != null &&
                    m.membershipNumber!
                        .toLowerCase()
                        .contains(query.toLowerCase())),
          )
          .toList();
    }
    return Right(filtered);
  }

  @override
  Future<Either<Failure, MemberDetail>> getMemberDetail(int id) async {
    if (errorMessage != null) {
      return Left(ServerFailure(errorMessage!));
    }
    return Right(
      detail ??
          MemberDetail(
            id: id,
            fullName: 'Stiven Hutapea',
            membershipNumber: 'MB-001',
            gender: 'Male',
            status: 'active',
            hasAppAccount: true,
          ),
    );
  }
}

void main() {
  final testMembers = [
    const MemberDirectoryItem(
      id: 1,
      fullName: 'Stiven Hutapea',
      membershipNumber: 'MB-001',
      gender: 'Male',
      status: 'active',
      maskedPhone: '0812****7890',
      hasAppAccount: true,
    ),
    const MemberDirectoryItem(
      id: 2,
      fullName: 'Maria Simanjuntak',
      membershipNumber: 'MB-002',
      gender: 'Female',
      status: 'active',
      maskedPhone: '0898****4321',
      hasAppAccount: false,
    ),
  ];

  Widget createWidgetToTest(FakeMemberRepository repo) {
    return ProviderScope(
      overrides: [
        memberRepositoryProvider.overrideWithValue(repo),
      ],
      child: const MaterialApp(
        home: DirectoryScreen(),
      ),
    );
  }

  testWidgets('renders search bar, privacy notice, and member list cleanly',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final repo = FakeMemberRepository(members: testMembers);

    await tester.pumpWidget(createWidgetToTest(repo));
    await tester.pumpAndSettle();

    expect(find.text('Direktori Jemaat'), findsOneWidget);
    expect(
      find.text('Kontak jemaat dilindungi dengan privasi sensorik (UU PDP).'),
      findsOneWidget,
    );
    expect(find.text('Stiven Hutapea'), findsOneWidget);
    expect(find.text('0812****7890'), findsOneWidget);
    expect(find.text('Maria Simanjuntak'), findsOneWidget);
  });

  testWidgets('renders empty state when no members match search query',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final repo = FakeMemberRepository(members: const []);

    await tester.pumpWidget(createWidgetToTest(repo));
    await tester.pumpAndSettle();

    expect(find.text('Jemaat tidak ditemukan'), findsOneWidget);
    expect(
      find.text('Coba kata kunci pencarian nama atau nomor anggota lain.'),
      findsOneWidget,
    );
  });

  testWidgets('renders error state when repository throws failure',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final repo =
        FakeMemberRepository(errorMessage: 'Koneksi internet terputus');

    await tester.pumpWidget(createWidgetToTest(repo));
    await tester.pumpAndSettle();

    expect(find.text('Gagal memuat direktori jemaat'), findsOneWidget);
    expect(find.text('Koneksi internet terputus'), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);
  });
}
