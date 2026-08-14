import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/donation_confirmation.dart';
import 'chart_of_account_model.dart';

part 'donation_confirmation_model.freezed.dart';
part 'donation_confirmation_model.g.dart';

@freezed
class DonationConfirmationModel with _$DonationConfirmationModel {
  const factory DonationConfirmationModel({
    required int id,
    @JsonKey(name: 'donation_number') required String donationNumber,
    @JsonKey(name: 'user_id') required int userId,
    @JsonKey(name: 'member_id') int? memberId,
    ChartOfAccountModel? category,
    required num amount,
    @JsonKey(name: 'transfer_date') required String transferDate,
    @JsonKey(name: 'sender_bank') required String senderBank,
    @JsonKey(name: 'depositor_phone') String? depositorPhone,
    @JsonKey(name: 'proof_file_url') String? proofFileUrl,
    required String status,
    String? notes,
    @JsonKey(name: 'rejection_reason') String? rejectionReason,
    @JsonKey(name: 'reviewed_at') String? reviewedAt,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
  }) = _DonationConfirmationModel;

  const DonationConfirmationModel._();

  factory DonationConfirmationModel.fromJson(Map<String, dynamic> json) =>
      _$DonationConfirmationModelFromJson(json);

  DonationConfirmation toEntity() {
    return DonationConfirmation(
      id: id,
      donationNumber: donationNumber,
      userId: userId,
      memberId: memberId,
      category: category?.toEntity(),
      amount: amount,
      transferDate: transferDate,
      senderBank: senderBank,
      depositorPhone: depositorPhone,
      proofFileUrl: proofFileUrl,
      status: status,
      notes: notes,
      rejectionReason: rejectionReason,
      reviewedAt: reviewedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
