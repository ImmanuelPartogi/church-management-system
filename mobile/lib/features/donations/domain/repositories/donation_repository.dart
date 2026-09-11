import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/church_bank_account.dart';
import '../entities/donation_confirmation.dart';

abstract class DonationRepository {
  Future<Either<Failure, List<ChurchBankAccount>>> getChurchBankAccounts();

  Future<Either<Failure, List<DonationConfirmation>>> getMyDonations({
    int page = 1,
    String? startDate,
    String? endDate,
    String? status,
    int? chartOfAccountId,
  });

  Future<Either<Failure, List<int>>> exportDonations({
    required String format,
    String? startDate,
    String? endDate,
    int? chartOfAccountId,
    String? status,
  });

  Future<Either<Failure, DonationConfirmation>> getDonationDetail(int id);

  Future<Either<Failure, DonationConfirmation>> submitDonationConfirmation({
    required int chartOfAccountId,
    required num amount,
    required String transferDate,
    required String senderBank,
    String? depositorPhone,
    String? notes,
    String? proofFilePath,
    void Function(int count, int total)? onSendProgress,
  });
}
