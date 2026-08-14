// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chart_of_account_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChartOfAccountModelImpl _$$ChartOfAccountModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ChartOfAccountModelImpl(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool,
    );

Map<String, dynamic> _$$ChartOfAccountModelImplToJson(
        _$ChartOfAccountModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'type': instance.type,
      'description': instance.description,
      'is_active': instance.isActive,
    };
