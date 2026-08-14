import 'package:church_management_mobile/core/error/failures.dart';
import 'package:church_management_mobile/features/hymns/data/repositories/hymn_repository_impl.dart';
import 'package:church_management_mobile/features/hymns/domain/entities/song.dart';
import 'package:church_management_mobile/features/hymns/domain/entities/songbook.dart';
import 'package:church_management_mobile/features/hymns/domain/repositories/hymn_repository.dart';
import 'package:church_management_mobile/features/hymns/presentation/screens/hymns_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

class FakeHymnRepository implements HymnRepository {
  final List<Songbook> songbooks;
  final List<Song> songs;

  FakeHymnRepository({
    this.songbooks = const [],
    this.songs = const [],
  });

  @override
  Future<Either<Failure, List<Songbook>>> getSongbooks() async {
    return Right(songbooks);
  }

  @override
  Future<Either<Failure, List<Song>>> getSongs({
    String? search,
    int? songbookId,
    int page = 1,
  }) async {
    var filtered = songs;

    if (songbookId != null) {
      filtered = filtered.where((s) => s.songbookId == songbookId).toList();
    }

    if (search != null && search.isNotEmpty) {
      filtered = filtered
          .where(
            (s) =>
                s.title.toLowerCase().contains(search.toLowerCase()) ||
                s.lyrics.toLowerCase().contains(search.toLowerCase()) ||
                s.number.toString() == search,
          )
          .toList();
    }

    return Right(filtered);
  }

  @override
  Future<Either<Failure, Song>> getSongDetail(int id) async {
    final song = songs.firstWhere(
      (s) => s.id == id,
      orElse: () => throw Exception('Not found'),
    );
    return Right(song);
  }
}

void main() {
  final testSongbooks = [
    const Songbook(id: 1, name: 'Buku Ende', code: 'BE', songCount: 10),
    const Songbook(id: 2, name: 'Buku Nyanyian', code: 'BN', songCount: 5),
  ];

  final testSongs = [
    const Song(
      id: 101,
      songbookId: 1,
      songbookCode: 'BE',
      songbookName: 'Buku Ende',
      number: 1,
      title: 'O Debata Trinunggal',
      lyrics: 'Bait 1: O Debata Trinunggal i.',
    ),
    const Song(
      id: 102,
      songbookId: 1,
      songbookCode: 'BE',
      songbookName: 'Buku Ende',
      number: 2,
      title: 'Na Taon Na Salpu I',
      lyrics: 'Bait 1: Na taon na salpu i.',
    ),
    const Song(
      id: 201,
      songbookId: 2,
      songbookCode: 'BN',
      songbookName: 'Buku Nyanyian',
      number: 1,
      title: 'Terpujilah Allah',
      lyrics: 'Bait 1: Terpujilah Allah Maha Kuasa.',
    ),
  ];

  Widget createWidgetToTest(FakeHymnRepository fakeRepo) {
    return ProviderScope(
      overrides: [
        hymnRepositoryProvider.overrideWithValue(fakeRepo),
      ],
      child: const MaterialApp(
        home: HymnsScreen(),
      ),
    );
  }

  testWidgets('renders search field, filter chips, and song list cleanly',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final repo = FakeHymnRepository(
      songbooks: testSongbooks,
      songs: testSongs,
    );

    await tester.pumpWidget(createWidgetToTest(repo));
    await tester.pumpAndSettle();

    expect(find.text('Buku Nyanyian & Kidung'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is TextField &&
            w.decoration?.hintText == 'Cari judul, nomor, atau lirik lagu...',
      ),
      findsOneWidget,
    );

    expect(find.text('Semua Buku'), findsOneWidget);
    expect(find.text('BE (Buku Ende)'), findsOneWidget);
    expect(find.text('BN (Buku Nyanyian)'), findsOneWidget);

    expect(find.text('O Debata Trinunggal'), findsOneWidget);
    expect(find.text('Na Taon Na Salpu I'), findsOneWidget);
    expect(find.text('Terpujilah Allah'), findsOneWidget);
  });

  testWidgets('renders empty state when no songs match search query',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final repo = FakeHymnRepository(
      songbooks: testSongbooks,
      songs: const [],
    );

    await tester.pumpWidget(createWidgetToTest(repo));
    await tester.pumpAndSettle();

    expect(find.text('Lagu tidak ditemukan'), findsOneWidget);
    expect(
      find.text('Coba kata kunci pencarian atau filter yang lain.'),
      findsOneWidget,
    );
  });
}
