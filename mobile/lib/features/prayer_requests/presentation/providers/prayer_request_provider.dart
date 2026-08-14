import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/prayer_request_repository_impl.dart';
import '../../domain/entities/prayer_request.dart';
import '../../domain/repositories/prayer_request_repository.dart';

final prayerRequestListProvider =
    FutureProvider<List<PrayerRequest>>((ref) async {
  final repository = ref.watch(prayerRequestRepositoryProvider);
  final result = await repository.getMyPrayerRequests(page: 1);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (list) => list,
  );
});

final prayerRequestDetailProvider =
    FutureProvider.family<PrayerRequest, int>((ref, id) async {
  final repository = ref.watch(prayerRequestRepositoryProvider);
  final result = await repository.getPrayerRequestDetail(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (prayerRequest) => prayerRequest,
  );
});

enum PrayerSubmissionStatus { idle, submitting, success, error }

class PrayerSubmissionState {
  final PrayerSubmissionStatus status;
  final PrayerRequest? submittedPrayerRequest;
  final String? errorMessage;

  const PrayerSubmissionState({
    required this.status,
    this.submittedPrayerRequest,
    this.errorMessage,
  });

  const PrayerSubmissionState.initial()
      : this(status: PrayerSubmissionStatus.idle);
}

class PrayerSubmissionNotifier extends StateNotifier<PrayerSubmissionState> {
  final PrayerRequestRepository _repository;

  PrayerSubmissionNotifier(this._repository)
      : super(const PrayerSubmissionState.initial());

  Future<void> submit({
    required String title,
    required String content,
    String? category,
    bool isPrivate = true,
  }) async {
    state = const PrayerSubmissionState(
      status: PrayerSubmissionStatus.submitting,
    );

    final result = await _repository.submitPrayerRequest(
      title: title,
      content: content,
      category: category,
      isPrivate: isPrivate,
    );

    result.fold(
      (failure) {
        state = PrayerSubmissionState(
          status: PrayerSubmissionStatus.error,
          errorMessage: failure.message,
        );
      },
      (prayerRequest) {
        state = PrayerSubmissionState(
          status: PrayerSubmissionStatus.success,
          submittedPrayerRequest: prayerRequest,
        );
      },
    );
  }

  void reset() {
    state = const PrayerSubmissionState.initial();
  }
}

final prayerSubmissionProvider =
    StateNotifierProvider<PrayerSubmissionNotifier, PrayerSubmissionState>(
        (ref) {
  final repository = ref.watch(prayerRequestRepositoryProvider);
  return PrayerSubmissionNotifier(repository);
});
