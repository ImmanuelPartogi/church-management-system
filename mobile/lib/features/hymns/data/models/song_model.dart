import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/song.dart';

part 'song_model.freezed.dart';
part 'song_model.g.dart';

@freezed
class SongModel with _$SongModel {
  const factory SongModel({
    required int id,
    @JsonKey(name: 'songbook_id') required int songbookId,
    @JsonKey(name: 'songbook_name') String? songbookName,
    @JsonKey(name: 'songbook_code') String? songbookCode,
    required int number,
    required String title,
    required String lyrics,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _SongModel;

  const SongModel._();

  factory SongModel.fromJson(Map<String, dynamic> json) =>
      _$SongModelFromJson(json);

  Song toEntity() {
    return Song(
      id: id,
      songbookId: songbookId,
      songbookName: songbookName,
      songbookCode: songbookCode,
      number: number,
      title: title,
      lyrics: lyrics,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
