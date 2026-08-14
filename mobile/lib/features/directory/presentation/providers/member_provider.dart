import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/member_repository_impl.dart';
import '../../domain/entities/member_detail.dart';
import '../../domain/entities/member_directory_item.dart';

final memberSearchQueryProvider = StateProvider<String>((ref) => '');

final memberDirectoryListProvider =
    FutureProvider<List<MemberDirectoryItem>>((ref) async {
  final repository = ref.watch(memberRepositoryProvider);
  final query = ref.watch(memberSearchQueryProvider);

  final result = await repository.searchMembers(
    query: query,
    page: 1,
  );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (list) => list,
  );
});

final memberDetailProvider =
    FutureProvider.family<MemberDetail, int>((ref, id) async {
  final repository = ref.watch(memberRepositoryProvider);
  final result = await repository.getMemberDetail(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (detail) => detail,
  );
});
