import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/entities/daily_verse.dart';

final dailyVerseProvider = FutureProvider<DailyVerse>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  final result = await repository.getDailyVerse();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (verse) => verse,
  );
});
