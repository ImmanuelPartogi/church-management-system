import 'chart_of_account.dart';

class DonationConfirmation {
  final int id;
  final String donationNumber;
  final int userId;
  final int? memberId;
  final ChartOfAccount? category;
  final num amount;
  final String transferDate;
  final String senderBank;
  final String? depositorPhone;
  final String? proofFileUrl;
  final String status;
  final String? notes;
  final String? rejectionReason;
  final String? reviewedAt;
  final String createdAt;
  final String updatedAt;

  const DonationConfirmation({
    required this.id,
    required this.donationNumber,
    required this.userId,
    this.memberId,
    this.category,
    required this.amount,
    required this.transferDate,
    required this.senderBank,
    this.depositorPhone,
    this.proofFileUrl,
    required this.status,
    this.notes,
    this.rejectionReason,
    this.reviewedAt,
    required this.createdAt,
    required this.updatedAt,
  });
}
