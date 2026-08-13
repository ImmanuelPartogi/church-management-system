// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_verse_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DailyVerseModelImpl _$$DailyVerseModelImplFromJson(
        Map<String, dynamic> json) =>
    _$DailyVerseModelImpl(
      id: (json['id'] as num).toInt(),
      verseReference: json['verse_reference'] as String,
      content: json['content'] as String,
      date: json['date'] as String?,
    );

Map<String, dynamic> _$$DailyVerseModelImplToJson(
        _$DailyVerseModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'verse_reference': instance.verseReference,
      'content': instance.content,
      'date': instance.date,
    };
