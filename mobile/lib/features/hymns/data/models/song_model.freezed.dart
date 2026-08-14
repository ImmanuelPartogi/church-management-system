// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'song_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SongModel _$SongModelFromJson(Map<String, dynamic> json) {
  return _SongModel.fromJson(json);
}

/// @nodoc
mixin _$SongModel {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'songbook_id')
  int get songbookId => throw _privateConstructorUsedError;
  @JsonKey(name: 'songbook_name')
  String? get songbookName => throw _privateConstructorUsedError;
  @JsonKey(name: 'songbook_code')
  String? get songbookCode => throw _privateConstructorUsedError;
  int get number => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get lyrics => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this SongModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SongModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SongModelCopyWith<SongModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SongModelCopyWith<$Res> {
  factory $SongModelCopyWith(SongModel value, $Res Function(SongModel) then) =
      _$SongModelCopyWithImpl<$Res, SongModel>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'songbook_id') int songbookId,
      @JsonKey(name: 'songbook_name') String? songbookName,
      @JsonKey(name: 'songbook_code') String? songbookCode,
      int number,
      String title,
      String lyrics,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt});
}

/// @nodoc
class _$SongModelCopyWithImpl<$Res, $Val extends SongModel>
    implements $SongModelCopyWith<$Res> {
  _$SongModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SongModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? songbookId = null,
    Object? songbookName = freezed,
    Object? songbookCode = freezed,
    Object? number = null,
    Object? title = null,
    Object? lyrics = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      songbookId: null == songbookId
          ? _value.songbookId
          : songbookId // ignore: cast_nullable_to_non_nullable
              as int,
      songbookName: freezed == songbookName
          ? _value.songbookName
          : songbookName // ignore: cast_nullable_to_non_nullable
              as String?,
      songbookCode: freezed == songbookCode
          ? _value.songbookCode
          : songbookCode // ignore: cast_nullable_to_non_nullable
              as String?,
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      lyrics: null == lyrics
          ? _value.lyrics
          : lyrics // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SongModelImplCopyWith<$Res>
    implements $SongModelCopyWith<$Res> {
  factory _$$SongModelImplCopyWith(
          _$SongModelImpl value, $Res Function(_$SongModelImpl) then) =
      __$$SongModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'songbook_id') int songbookId,
      @JsonKey(name: 'songbook_name') String? songbookName,
      @JsonKey(name: 'songbook_code') String? songbookCode,
      int number,
      String title,
      String lyrics,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt});
}

/// @nodoc
class __$$SongModelImplCopyWithImpl<$Res>
    extends _$SongModelCopyWithImpl<$Res, _$SongModelImpl>
    implements _$$SongModelImplCopyWith<$Res> {
  __$$SongModelImplCopyWithImpl(
      _$SongModelImpl _value, $Res Function(_$SongModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SongModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? songbookId = null,
    Object? songbookName = freezed,
    Object? songbookCode = freezed,
    Object? number = null,
    Object? title = null,
    Object? lyrics = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$SongModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      songbookId: null == songbookId
          ? _value.songbookId
          : songbookId // ignore: cast_nullable_to_non_nullable
              as int,
      songbookName: freezed == songbookName
          ? _value.songbookName
          : songbookName // ignore: cast_nullable_to_non_nullable
              as String?,
      songbookCode: freezed == songbookCode
          ? _value.songbookCode
          : songbookCode // ignore: cast_nullable_to_non_nullable
              as String?,
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      lyrics: null == lyrics
          ? _value.lyrics
          : lyrics // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SongModelImpl extends _SongModel {
  const _$SongModelImpl(
      {required this.id,
      @JsonKey(name: 'songbook_id') required this.songbookId,
      @JsonKey(name: 'songbook_name') this.songbookName,
      @JsonKey(name: 'songbook_code') this.songbookCode,
      required this.number,
      required this.title,
      required this.lyrics,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : super._();

  factory _$SongModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SongModelImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'songbook_id')
  final int songbookId;
  @override
  @JsonKey(name: 'songbook_name')
  final String? songbookName;
  @override
  @JsonKey(name: 'songbook_code')
  final String? songbookCode;
  @override
  final int number;
  @override
  final String title;
  @override
  final String lyrics;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @override
  String toString() {
    return 'SongModel(id: $id, songbookId: $songbookId, songbookName: $songbookName, songbookCode: $songbookCode, number: $number, title: $title, lyrics: $lyrics, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SongModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.songbookId, songbookId) ||
                other.songbookId == songbookId) &&
            (identical(other.songbookName, songbookName) ||
                other.songbookName == songbookName) &&
            (identical(other.songbookCode, songbookCode) ||
                other.songbookCode == songbookCode) &&
            (identical(other.number, number) || other.number == number) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.lyrics, lyrics) || other.lyrics == lyrics) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, songbookId, songbookName,
      songbookCode, number, title, lyrics, createdAt, updatedAt);

  /// Create a copy of SongModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SongModelImplCopyWith<_$SongModelImpl> get copyWith =>
      __$$SongModelImplCopyWithImpl<_$SongModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SongModelImplToJson(
      this,
    );
  }
}

abstract class _SongModel extends SongModel {
  const factory _SongModel(
      {required final int id,
      @JsonKey(name: 'songbook_id') required final int songbookId,
      @JsonKey(name: 'songbook_name') final String? songbookName,
      @JsonKey(name: 'songbook_code') final String? songbookCode,
      required final int number,
      required final String title,
      required final String lyrics,
      @JsonKey(name: 'created_at') final String? createdAt,
      @JsonKey(name: 'updated_at') final String? updatedAt}) = _$SongModelImpl;
  const _SongModel._() : super._();

  factory _SongModel.fromJson(Map<String, dynamic> json) =
      _$SongModelImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'songbook_id')
  int get songbookId;
  @override
  @JsonKey(name: 'songbook_name')
  String? get songbookName;
  @override
  @JsonKey(name: 'songbook_code')
  String? get songbookCode;
  @override
  int get number;
  @override
  String get title;
  @override
  String get lyrics;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String? get updatedAt;

  /// Create a copy of SongModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SongModelImplCopyWith<_$SongModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
