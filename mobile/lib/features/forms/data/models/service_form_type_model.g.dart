// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_form_type_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ServiceFormTypeModelImpl _$$ServiceFormTypeModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ServiceFormTypeModelImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      feeAmount: json['fee_amount'] as num,
      active: json['active'] as bool,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$$ServiceFormTypeModelImplToJson(
        _$ServiceFormTypeModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'fee_amount': instance.feeAmount,
      'active': instance.active,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
