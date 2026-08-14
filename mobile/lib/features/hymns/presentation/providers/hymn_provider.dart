import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/hymn_repository_impl.dart';
import '../../domain/entities/song.dart';
import '../../domain/entities/songbook.dart';

final songbooksProvider = FutureProvider<List<Songbook>>((ref) async {
  final repository = ref.watch(hymnRepositoryProvider);
  final result = await repository.getSongbooks();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (list) => list,
  );
});

final hymnSearchQueryProvider = StateProvider<String>((ref) => '');

final hymnSongbookFilterProvider = StateProvider<int?>((ref) => null);

final hymnListProvider = FutureProvider<List<Song>>((ref) async {
  final repository = ref.watch(hymnRepositoryProvider);
  final search = ref.watch(hymnSearchQueryProvider);
  final songbookId = ref.watch(hymnSongbookFilterProvider);

  final result = await repository.getSongs(
    search: search,
    songbookId: songbookId,
    page: 1,
  );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (list) => list,
  );
});

final songDetailProvider = FutureProvider.family<Song, int>((ref, id) async {
  final repository = ref.watch(hymnRepositoryProvider);
  final result = await repository.getSongDetail(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (song) => song,
  );
});
