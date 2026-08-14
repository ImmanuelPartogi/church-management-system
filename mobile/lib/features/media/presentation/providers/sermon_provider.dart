import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/sermon_repository_impl.dart';
import '../../domain/entities/sermon.dart';

final sermonSearchQueryProvider = StateProvider<String>((ref) => '');

final sermonListProvider = FutureProvider<List<Sermon>>((ref) async {
  final repository = ref.watch(sermonRepositoryProvider);
  final search = ref.watch(sermonSearchQueryProvider);

  final result = await repository.getSermons(
    search: search,
    page: 1,
  );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (list) => list,
  );
});

final sermonDetailProvider =
    FutureProvider.family<Sermon, int>((ref, id) async {
  final repository = ref.watch(sermonRepositoryProvider);
  final result = await repository.getSermonDetail(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (sermon) => sermon,
  );
});
