// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'songbook_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SongbookModelImpl _$$SongbookModelImplFromJson(Map<String, dynamic> json) =>
    _$SongbookModelImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      code: json['code'] as String,
      description: json['description'] as String?,
      songCount: (json['song_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$SongbookModelImplToJson(_$SongbookModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'description': instance.description,
      'song_count': instance.songCount,
    };
