import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasource/search_remote_datasource.dart';
import '../../data/repositories/search_repository_impl.dart';
import '../../domain/entities/global_search_result.dart';
import '../../domain/repositories/search_repository.dart';

final searchRemoteDataSourceProvider = Provider<SearchRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return SearchRemoteDataSourceImpl(dio);
});

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final remoteDataSource = ref.watch(searchRemoteDataSourceProvider);
  return SearchRepositoryImpl(remoteDataSource);
});

final searchQueryStateProvider = StateProvider<String>((ref) => '');

final searchCategoryFilterProvider = StateProvider<String>((ref) => 'all');

final globalSearchResultProvider =
    FutureProvider.autoDispose<GlobalSearchResult?>((ref) async {
  final query = ref.watch(searchQueryStateProvider).trim();
  if (query.length < 2) {
    return null;
  }

  final repository = ref.watch(searchRepositoryProvider);
  final result = await repository.search(query);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (data) => data,
  );
});
