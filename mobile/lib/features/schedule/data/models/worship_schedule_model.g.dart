// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worship_schedule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorshipScheduleModelImpl _$$WorshipScheduleModelImplFromJson(
        Map<String, dynamic> json) =>
    _$WorshipScheduleModelImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      day: json['day'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String?,
      location: json['location'] as String?,
      active: json['active'] as bool,
    );

Map<String, dynamic> _$$WorshipScheduleModelImplToJson(
        _$WorshipScheduleModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'day': instance.day,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'location': instance.location,
      'active': instance.active,
    };
