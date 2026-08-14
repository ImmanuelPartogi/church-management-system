import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/sermon.dart';

part 'sermon_model.freezed.dart';
part 'sermon_model.g.dart';

@freezed
class SermonModel with _$SermonModel {
  const factory SermonModel({
    required int id,
    required String title,
    String? description,
    @JsonKey(name: 'preacher_name') required String preacherName,
    @JsonKey(name: 'file_name') String? fileName,
    @JsonKey(name: 'file_size') int? fileSize,
    @JsonKey(name: 'mime_type') String? mimeType,
    @JsonKey(name: 'download_count') @Default(0) int downloadCount,
    @JsonKey(name: 'published_at') String? publishedAt,
    @JsonKey(name: 'is_published') @Default(true) bool isPublished,
  }) = _SermonModel;

  const SermonModel._();

  factory SermonModel.fromJson(Map<String, dynamic> json) =>
      _$SermonModelFromJson(json);

  Sermon toEntity() => Sermon(
        id: id,
        title: title,
        description: description,
        preacherName: preacherName,
        fileName: fileName,
        fileSize: fileSize,
        mimeType: mimeType,
        downloadCount: downloadCount,
        publishedAt: publishedAt,
        isPublished: isPublished,
      );
}
