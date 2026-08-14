// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sermon_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SermonModelImpl _$$SermonModelImplFromJson(Map<String, dynamic> json) =>
    _$SermonModelImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      preacherName: json['preacher_name'] as String,
      fileName: json['file_name'] as String?,
      fileSize: (json['file_size'] as num?)?.toInt(),
      mimeType: json['mime_type'] as String?,
      downloadCount: (json['download_count'] as num?)?.toInt() ?? 0,
      publishedAt: json['published_at'] as String?,
      isPublished: json['is_published'] as bool? ?? true,
    );

Map<String, dynamic> _$$SermonModelImplToJson(_$SermonModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'preacher_name': instance.preacherName,
      'file_name': instance.fileName,
      'file_size': instance.fileSize,
      'mime_type': instance.mimeType,
      'download_count': instance.downloadCount,
      'published_at': instance.publishedAt,
      'is_published': instance.isPublished,
    };
