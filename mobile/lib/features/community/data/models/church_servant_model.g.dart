// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'church_servant_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChurchServantModelImpl _$$ChurchServantModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ChurchServantModelImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      role: json['role'] as String,
      roleLabel: json['role_label'] as String,
      maskedPhone: json['masked_phone'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      description: json['description'] as String?,
      active: json['active'] as bool? ?? true,
      resortName: json['resort_name'] as String?,
      sectorName: json['sector_name'] as String?,
      fellowshipName: json['fellowship_name'] as String?,
    );

Map<String, dynamic> _$$ChurchServantModelImplToJson(
        _$ChurchServantModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'role': instance.role,
      'role_label': instance.roleLabel,
      'masked_phone': instance.maskedPhone,
      'phone': instance.phone,
      'email': instance.email,
      'description': instance.description,
      'active': instance.active,
      'resort_name': instance.resortName,
      'sector_name': instance.sectorName,
      'fellowship_name': instance.fellowshipName,
    };
