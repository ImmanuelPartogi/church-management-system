import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/songbook.dart';

part 'songbook_model.freezed.dart';
part 'songbook_model.g.dart';

@freezed
class SongbookModel with _$SongbookModel {
  const factory SongbookModel({
    required int id,
    required String name,
    required String code,
    String? description,
    @JsonKey(name: 'song_count') int? songCount,
  }) = _SongbookModel;

  const SongbookModel._();

  factory SongbookModel.fromJson(Map<String, dynamic> json) =>
      _$SongbookModelFromJson(json);

  Songbook toEntity() {
    return Songbook(
      id: id,
      name: name,
      code: code,
      description: description,
      songCount: songCount,
    );
  }
}
