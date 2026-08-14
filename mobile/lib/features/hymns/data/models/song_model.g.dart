// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SongModelImpl _$$SongModelImplFromJson(Map<String, dynamic> json) =>
    _$SongModelImpl(
      id: (json['id'] as num).toInt(),
      songbookId: (json['songbook_id'] as num).toInt(),
      songbookName: json['songbook_name'] as String?,
      songbookCode: json['songbook_code'] as String?,
      number: (json['number'] as num).toInt(),
      title: json['title'] as String,
      lyrics: json['lyrics'] as String,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$$SongModelImplToJson(_$SongModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'songbook_id': instance.songbookId,
      'songbook_name': instance.songbookName,
      'songbook_code': instance.songbookCode,
      'number': instance.number,
      'title': instance.title,
      'lyrics': instance.lyrics,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
