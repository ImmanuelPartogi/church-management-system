import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/warta.dart';

part 'warta_model.freezed.dart';
part 'warta_model.g.dart';

@freezed
class WartaModel with _$WartaModel {
  const factory WartaModel({
    required int id,
    required String title,
    String? description,
    @JsonKey(name: 'file_name') required String fileName,
    @JsonKey(name: 'file_size') required int fileSize,
    @JsonKey(name: 'mime_type') required String mimeType,
    @JsonKey(name: 'published_at') required String publishedAt,
    @JsonKey(name: 'is_published') required bool isPublished,
    @JsonKey(name: 'download_count') required int downloadCount,
  }) = _WartaModel;

  const WartaModel._();

  factory WartaModel.fromJson(Map<String, dynamic> json) =>
      _$WartaModelFromJson(json);

  Warta toEntity() {
    return Warta(
      id: id,
      title: title,
      description: description,
      fileName: fileName,
      fileSize: fileSize,
      mimeType: mimeType,
      publishedAt: publishedAt,
      isPublished: isPublished,
      downloadCount: downloadCount,
    );
  }
}
