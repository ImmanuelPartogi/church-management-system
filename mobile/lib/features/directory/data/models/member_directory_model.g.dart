// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_directory_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MemberDirectoryModelImpl _$$MemberDirectoryModelImplFromJson(
        Map<String, dynamic> json) =>
    _$MemberDirectoryModelImpl(
      id: (json['id'] as num).toInt(),
      membershipNumber: json['membership_number'] as String?,
      fullName: json['full_name'] as String,
      gender: json['gender'] as String?,
      status: json['status'] as String?,
      maskedPhone: json['masked_phone'] as String?,
      hasAppAccount: json['has_app_account'] as bool? ?? false,
    );

Map<String, dynamic> _$$MemberDirectoryModelImplToJson(
        _$MemberDirectoryModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'membership_number': instance.membershipNumber,
      'full_name': instance.fullName,
      'gender': instance.gender,
      'status': instance.status,
      'masked_phone': instance.maskedPhone,
      'has_app_account': instance.hasAppAccount,
    };
