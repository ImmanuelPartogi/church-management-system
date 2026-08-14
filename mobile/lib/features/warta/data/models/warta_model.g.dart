// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warta_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WartaModelImpl _$$WartaModelImplFromJson(Map<String, dynamic> json) =>
    _$WartaModelImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      fileName: json['file_name'] as String,
      fileSize: (json['file_size'] as num).toInt(),
      mimeType: json['mime_type'] as String,
      publishedAt: json['published_at'] as String,
      isPublished: json['is_published'] as bool,
      downloadCount: (json['download_count'] as num).toInt(),
    );

Map<String, dynamic> _$$WartaModelImplToJson(_$WartaModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'file_name': instance.fileName,
      'file_size': instance.fileSize,
      'mime_type': instance.mimeType,
      'published_at': instance.publishedAt,
      'is_published': instance.isPublished,
      'download_count': instance.downloadCount,
    };
