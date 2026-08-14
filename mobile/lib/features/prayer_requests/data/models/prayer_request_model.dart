import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/prayer_request.dart';

part 'prayer_request_model.freezed.dart';
part 'prayer_request_model.g.dart';

@freezed
class PrayerRequestModel with _$PrayerRequestModel {
  const factory PrayerRequestModel({
    required int id,
    @JsonKey(name: 'user_id') required int userId,
    @JsonKey(name: 'member_id') int? memberId,
    required String title,
    required String content,
    String? category,
    @JsonKey(name: 'is_private') required bool isPrivate,
    required String status,
    @JsonKey(name: 'follow_up_notes') String? followUpNotes,
    @JsonKey(name: 'followed_up_at') String? followedUpAt,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
  }) = _PrayerRequestModel;

  const PrayerRequestModel._();

  factory PrayerRequestModel.fromJson(Map<String, dynamic> json) =>
      _$PrayerRequestModelFromJson(json);

  PrayerRequest toEntity() {
    return PrayerRequest(
      id: id,
      userId: userId,
      memberId: memberId,
      title: title,
      content: content,
      category: category,
      isPrivate: isPrivate,
      status: status,
      followUpNotes: followUpNotes,
      followedUpAt: followedUpAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
