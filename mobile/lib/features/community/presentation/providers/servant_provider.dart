import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/servant_repository_impl.dart';
import '../../domain/entities/church_servant.dart';

final servantRoleFilterProvider = StateProvider<String?>((ref) => null);
final servantSearchQueryProvider = StateProvider<String>((ref) => '');

final servantListProvider = FutureProvider<List<ChurchServant>>((ref) async {
  final repository = ref.watch(servantRepositoryProvider);
  final role = ref.watch(servantRoleFilterProvider);
  final search = ref.watch(servantSearchQueryProvider);

  final result = await repository.getServants(
    role: role,
    search: search,
    page: 1,
  );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (list) => list,
  );
});

final servantDetailProvider =
    FutureProvider.family<ChurchServant, int>((ref, id) async {
  final repository = ref.watch(servantRepositoryProvider);
  final result = await repository.getServantDetail(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (servant) => servant,
  );
});
