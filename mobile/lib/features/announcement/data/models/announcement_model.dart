import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/announcement.dart';

part 'announcement_model.freezed.dart';
part 'announcement_model.g.dart';

@freezed
class AnnouncementModel with _$AnnouncementModel {
  const factory AnnouncementModel({
    required int id,
    required String title,
    required String content,
    String? image,
    @JsonKey(name: 'published_at') String? publishedAt,
    required String status,
  }) = _AnnouncementModel;

  const AnnouncementModel._();

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementModelFromJson(json);

  Announcement toEntity() {
    return Announcement(
      id: id,
      title: title,
      content: content,
      image: image,
      publishedAt: publishedAt,
      status: status,
    );
  }
}
