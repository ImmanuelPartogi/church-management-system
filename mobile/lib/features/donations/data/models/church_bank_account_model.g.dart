// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'church_bank_account_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChurchBankAccountModelImpl _$$ChurchBankAccountModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ChurchBankAccountModelImpl(
      id: (json['id'] as num).toInt(),
      bankName: json['bank_name'] as String,
      accountNumber: json['account_number'] as String,
      accountHolderName: json['account_holder_name'] as String,
      isActive: json['is_active'] as bool,
      displayOrder: (json['display_order'] as num).toInt(),
    );

Map<String, dynamic> _$$ChurchBankAccountModelImplToJson(
        _$ChurchBankAccountModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bank_name': instance.bankName,
      'account_number': instance.accountNumber,
      'account_holder_name': instance.accountHolderName,
      'is_active': instance.isActive,
      'display_order': instance.displayOrder,
    };
