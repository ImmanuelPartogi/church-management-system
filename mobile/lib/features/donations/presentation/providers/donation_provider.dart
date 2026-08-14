import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/donation_repository_impl.dart';
import '../../domain/entities/church_bank_account.dart';
import '../../domain/entities/donation_confirmation.dart';
import '../../domain/repositories/donation_repository.dart';

final churchBankAccountsProvider =
    FutureProvider<List<ChurchBankAccount>>((ref) async {
  final repository = ref.watch(donationRepositoryProvider);
  final result = await repository.getChurchBankAccounts();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (list) => list,
  );
});

final donationHistoryProvider =
    FutureProvider<List<DonationConfirmation>>((ref) async {
  final repository = ref.watch(donationRepositoryProvider);
  final result = await repository.getMyDonations(page: 1);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (list) => list,
  );
});

final donationDetailProvider =
    FutureProvider.family<DonationConfirmation, int>((ref, id) async {
  final repository = ref.watch(donationRepositoryProvider);
  final result = await repository.getDonationDetail(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (donation) => donation,
  );
});

enum SubmissionStatus { idle, submitting, success, error }

class DonationSubmissionState {
  final SubmissionStatus status;
  final double uploadProgress;
  final DonationConfirmation? submittedDonation;
  final String? errorMessage;

  const DonationSubmissionState({
    required this.status,
    this.uploadProgress = 0.0,
    this.submittedDonation,
    this.errorMessage,
  });

  const DonationSubmissionState.initial() : this(status: SubmissionStatus.idle);
}

class DonationSubmissionNotifier
    extends StateNotifier<DonationSubmissionState> {
  final DonationRepository _repository;

  DonationSubmissionNotifier(this._repository)
      : super(const DonationSubmissionState.initial());

  Future<void> submit({
    required int chartOfAccountId,
    required num amount,
    required String transferDate,
    required String senderBank,
    String? depositorPhone,
    String? notes,
    String? proofFilePath,
  }) async {
    state = const DonationSubmissionState(
      status: SubmissionStatus.submitting,
      uploadProgress: 0.0,
    );

    final result = await _repository.submitDonationConfirmation(
      chartOfAccountId: chartOfAccountId,
      amount: amount,
      transferDate: transferDate,
      senderBank: senderBank,
      depositorPhone: depositorPhone,
      notes: notes,
      proofFilePath: proofFilePath,
      onSendProgress: (count, total) {
        if (total > 0) {
          final progress = count / total;
          state = DonationSubmissionState(
            status: SubmissionStatus.submitting,
            uploadProgress: progress,
          );
        }
      },
    );

    result.fold(
      (failure) {
        state = DonationSubmissionState(
          status: SubmissionStatus.error,
          errorMessage: failure.message,
        );
      },
      (donation) {
        state = DonationSubmissionState(
          status: SubmissionStatus.success,
          uploadProgress: 1.0,
          submittedDonation: donation,
        );
      },
    );
  }

  void reset() {
    state = const DonationSubmissionState.initial();
  }
}

final donationSubmissionProvider =
    StateNotifierProvider<DonationSubmissionNotifier, DonationSubmissionState>(
        (ref) {
  final repository = ref.watch(donationRepositoryProvider);
  return DonationSubmissionNotifier(repository);
});
