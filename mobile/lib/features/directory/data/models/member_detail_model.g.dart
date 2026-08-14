// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MemberDetailModelImpl _$$MemberDetailModelImplFromJson(
        Map<String, dynamic> json) =>
    _$MemberDetailModelImpl(
      id: (json['id'] as num).toInt(),
      membershipNumber: json['membership_number'] as String?,
      fullName: json['full_name'] as String,
      gender: json['gender'] as String?,
      birthDate: json['birth_date'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      baptismDate: json['baptism_date'] as String?,
      status: json['status'] as String?,
      hasAppAccount: json['has_app_account'] as bool? ?? false,
    );

Map<String, dynamic> _$$MemberDetailModelImplToJson(
        _$MemberDetailModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'membership_number': instance.membershipNumber,
      'full_name': instance.fullName,
      'gender': instance.gender,
      'birth_date': instance.birthDate,
      'phone': instance.phone,
      'email': instance.email,
      'address': instance.address,
      'baptism_date': instance.baptismDate,
      'status': instance.status,
      'has_app_account': instance.hasAppAccount,
    };
