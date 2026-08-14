// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PrayerRequestModelImpl _$$PrayerRequestModelImplFromJson(
        Map<String, dynamic> json) =>
    _$PrayerRequestModelImpl(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      memberId: (json['member_id'] as num?)?.toInt(),
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String?,
      isPrivate: json['is_private'] as bool,
      status: json['status'] as String,
      followUpNotes: json['follow_up_notes'] as String?,
      followedUpAt: json['followed_up_at'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$$PrayerRequestModelImplToJson(
        _$PrayerRequestModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'member_id': instance.memberId,
      'title': instance.title,
      'content': instance.content,
      'category': instance.category,
      'is_private': instance.isPrivate,
      'status': instance.status,
      'follow_up_notes': instance.followUpNotes,
      'followed_up_at': instance.followedUpAt,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
