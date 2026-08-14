// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_form_application_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ServiceFormApplicationModelImpl _$$ServiceFormApplicationModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ServiceFormApplicationModelImpl(
      id: (json['id'] as num).toInt(),
      applicationNumber: json['application_number'] as String,
      userId: (json['user_id'] as num).toInt(),
      memberId: (json['member_id'] as num?)?.toInt(),
      serviceFormType: json['service_form_type'] == null
          ? null
          : ServiceFormTypeModel.fromJson(
              json['service_form_type'] as Map<String, dynamic>),
      status: json['status'] as String,
      applicantNotes: json['applicant_notes'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      paymentStatus: json['payment_status'] as String,
      paymentNotes: json['payment_notes'] as String?,
      reviewedAt: json['reviewed_at'] as String?,
      documents: (json['documents'] as List<dynamic>?)
              ?.map((e) =>
                  ServiceFormDocumentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$$ServiceFormApplicationModelImplToJson(
        _$ServiceFormApplicationModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'application_number': instance.applicationNumber,
      'user_id': instance.userId,
      'member_id': instance.memberId,
      'service_form_type': instance.serviceFormType,
      'status': instance.status,
      'applicant_notes': instance.applicantNotes,
      'rejection_reason': instance.rejectionReason,
      'payment_status': instance.paymentStatus,
      'payment_notes': instance.paymentNotes,
      'reviewed_at': instance.reviewedAt,
      'documents': instance.documents,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
