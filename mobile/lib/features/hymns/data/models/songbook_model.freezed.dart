// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'songbook_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SongbookModel _$SongbookModelFromJson(Map<String, dynamic> json) {
  return _SongbookModel.fromJson(json);
}

/// @nodoc
mixin _$SongbookModel {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'song_count')
  int? get songCount => throw _privateConstructorUsedError;

  /// Serializes this SongbookModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SongbookModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SongbookModelCopyWith<SongbookModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SongbookModelCopyWith<$Res> {
  factory $SongbookModelCopyWith(
          SongbookModel value, $Res Function(SongbookModel) then) =
      _$SongbookModelCopyWithImpl<$Res, SongbookModel>;
  @useResult
  $Res call(
      {int id,
      String name,
      String code,
      String? description,
      @JsonKey(name: 'song_count') int? songCount});
}

/// @nodoc
class _$SongbookModelCopyWithImpl<$Res, $Val extends SongbookModel>
    implements $SongbookModelCopyWith<$Res> {
  _$SongbookModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SongbookModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? code = null,
    Object? description = freezed,
    Object? songCount = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      songCount: freezed == songCount
          ? _value.songCount
          : songCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SongbookModelImplCopyWith<$Res>
    implements $SongbookModelCopyWith<$Res> {
  factory _$$SongbookModelImplCopyWith(
          _$SongbookModelImpl value, $Res Function(_$SongbookModelImpl) then) =
      __$$SongbookModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String code,
      String? description,
      @JsonKey(name: 'song_count') int? songCount});
}

/// @nodoc
class __$$SongbookModelImplCopyWithImpl<$Res>
    extends _$SongbookModelCopyWithImpl<$Res, _$SongbookModelImpl>
    implements _$$SongbookModelImplCopyWith<$Res> {
  __$$SongbookModelImplCopyWithImpl(
      _$SongbookModelImpl _value, $Res Function(_$SongbookModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SongbookModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? code = null,
    Object? description = freezed,
    Object? songCount = freezed,
  }) {
    return _then(_$SongbookModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      songCount: freezed == songCount
          ? _value.songCount
          : songCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SongbookModelImpl extends _SongbookModel {
  const _$SongbookModelImpl(
      {required this.id,
      required this.name,
      required this.code,
      this.description,
      @JsonKey(name: 'song_count') this.songCount})
      : super._();

  factory _$SongbookModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SongbookModelImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String code;
  @override
  final String? description;
  @override
  @JsonKey(name: 'song_count')
  final int? songCount;

  @override
  String toString() {
    return 'SongbookModel(id: $id, name: $name, code: $code, description: $description, songCount: $songCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SongbookModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.songCount, songCount) ||
                other.songCount == songCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, code, description, songCount);

  /// Create a copy of SongbookModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SongbookModelImplCopyWith<_$SongbookModelImpl> get copyWith =>
      __$$SongbookModelImplCopyWithImpl<_$SongbookModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SongbookModelImplToJson(
      this,
    );
  }
}

abstract class _SongbookModel extends SongbookModel {
  const factory _SongbookModel(
      {required final int id,
      required final String name,
      required final String code,
      final String? description,
      @JsonKey(name: 'song_count') final int? songCount}) = _$SongbookModelImpl;
  const _SongbookModel._() : super._();

  factory _SongbookModel.fromJson(Map<String, dynamic> json) =
      _$SongbookModelImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get code;
  @override
  String? get description;
  @override
  @JsonKey(name: 'song_count')
  int? get songCount;

  /// Create a copy of SongbookModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SongbookModelImplCopyWith<_$SongbookModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
