import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/announcement_repository_impl.dart';
import '../../domain/entities/announcement.dart';

final announcementListProvider =
    FutureProvider<List<Announcement>>((ref) async {
  final repository = ref.watch(announcementRepositoryProvider);
  final result = await repository.getAnnouncements(page: 1);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (list) => list,
  );
});
