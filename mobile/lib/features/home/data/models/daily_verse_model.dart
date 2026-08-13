import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/daily_verse.dart';

part 'daily_verse_model.freezed.dart';
part 'daily_verse_model.g.dart';

@freezed
class DailyVerseModel with _$DailyVerseModel {
  const factory DailyVerseModel({
    required int id,
    @JsonKey(name: 'verse_reference') required String verseReference,
    required String content,
    String? date,
  }) = _DailyVerseModel;

  const DailyVerseModel._();

  factory DailyVerseModel.fromJson(Map<String, dynamic> json) =>
      _$DailyVerseModelFromJson(json);

  DailyVerse toEntity() {
    return DailyVerse(
      id: id,
      verseReference: verseReference,
      content: content,
      date: date,
    );
  }
}
