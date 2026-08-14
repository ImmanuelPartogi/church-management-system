// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_form_document_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ServiceFormDocumentModelImpl _$$ServiceFormDocumentModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ServiceFormDocumentModelImpl(
      id: (json['id'] as num).toInt(),
      serviceFormApplicationId:
          (json['service_form_application_id'] as num).toInt(),
      documentName: json['document_name'] as String,
      fileName: json['file_name'] as String,
      mimeType: json['mime_type'] as String,
      fileSize: (json['file_size'] as num).toInt(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$$ServiceFormDocumentModelImplToJson(
        _$ServiceFormDocumentModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'service_form_application_id': instance.serviceFormApplicationId,
      'document_name': instance.documentName,
      'file_name': instance.fileName,
      'mime_type': instance.mimeType,
      'file_size': instance.fileSize,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
