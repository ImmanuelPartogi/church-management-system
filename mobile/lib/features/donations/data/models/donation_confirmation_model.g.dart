// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'donation_confirmation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DonationConfirmationModelImpl _$$DonationConfirmationModelImplFromJson(
        Map<String, dynamic> json) =>
    _$DonationConfirmationModelImpl(
      id: (json['id'] as num).toInt(),
      donationNumber: json['donation_number'] as String,
      userId: (json['user_id'] as num).toInt(),
      memberId: (json['member_id'] as num?)?.toInt(),
      category: json['category'] == null
          ? null
          : ChartOfAccountModel.fromJson(
              json['category'] as Map<String, dynamic>),
      amount: json['amount'] as num,
      transferDate: json['transfer_date'] as String,
      senderBank: json['sender_bank'] as String,
      depositorPhone: json['depositor_phone'] as String?,
      proofFileUrl: json['proof_file_url'] as String?,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      reviewedAt: json['reviewed_at'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$$DonationConfirmationModelImplToJson(
        _$DonationConfirmationModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'donation_number': instance.donationNumber,
      'user_id': instance.userId,
      'member_id': instance.memberId,
      'category': instance.category,
      'amount': instance.amount,
      'transfer_date': instance.transferDate,
      'sender_bank': instance.senderBank,
      'depositor_phone': instance.depositorPhone,
      'proof_file_url': instance.proofFileUrl,
      'status': instance.status,
      'notes': instance.notes,
      'rejection_reason': instance.rejectionReason,
      'reviewed_at': instance.reviewedAt,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
