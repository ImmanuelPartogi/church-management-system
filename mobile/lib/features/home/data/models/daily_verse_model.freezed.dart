// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_verse_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DailyVerseModel _$DailyVerseModelFromJson(Map<String, dynamic> json) {
  return _DailyVerseModel.fromJson(json);
}

/// @nodoc
mixin _$DailyVerseModel {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'verse_reference')
  String get verseReference => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String? get date => throw _privateConstructorUsedError;

  /// Serializes this DailyVerseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyVerseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyVerseModelCopyWith<DailyVerseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyVerseModelCopyWith<$Res> {
  factory $DailyVerseModelCopyWith(
          DailyVerseModel value, $Res Function(DailyVerseModel) then) =
      _$DailyVerseModelCopyWithImpl<$Res, DailyVerseModel>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'verse_reference') String verseReference,
      String content,
      String? date});
}

/// @nodoc
class _$DailyVerseModelCopyWithImpl<$Res, $Val extends DailyVerseModel>
    implements $DailyVerseModelCopyWith<$Res> {
  _$DailyVerseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyVerseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? verseReference = null,
    Object? content = null,
    Object? date = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      verseReference: null == verseReference
          ? _value.verseReference
          : verseReference // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      date: freezed == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DailyVerseModelImplCopyWith<$Res>
    implements $DailyVerseModelCopyWith<$Res> {
  factory _$$DailyVerseModelImplCopyWith(_$DailyVerseModelImpl value,
          $Res Function(_$DailyVerseModelImpl) then) =
      __$$DailyVerseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'verse_reference') String verseReference,
      String content,
      String? date});
}

/// @nodoc
class __$$DailyVerseModelImplCopyWithImpl<$Res>
    extends _$DailyVerseModelCopyWithImpl<$Res, _$DailyVerseModelImpl>
    implements _$$DailyVerseModelImplCopyWith<$Res> {
  __$$DailyVerseModelImplCopyWithImpl(
      _$DailyVerseModelImpl _value, $Res Function(_$DailyVerseModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of DailyVerseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? verseReference = null,
    Object? content = null,
    Object? date = freezed,
  }) {
    return _then(_$DailyVerseModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      verseReference: null == verseReference
          ? _value.verseReference
          : verseReference // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      date: freezed == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyVerseModelImpl extends _DailyVerseModel {
  const _$DailyVerseModelImpl(
      {required this.id,
      @JsonKey(name: 'verse_reference') required this.verseReference,
      required this.content,
      this.date})
      : super._();

  factory _$DailyVerseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyVerseModelImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'verse_reference')
  final String verseReference;
  @override
  final String content;
  @override
  final String? date;

  @override
  String toString() {
    return 'DailyVerseModel(id: $id, verseReference: $verseReference, content: $content, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyVerseModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.verseReference, verseReference) ||
                other.verseReference == verseReference) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.date, date) || other.date == date));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, verseReference, content, date);

  /// Create a copy of DailyVerseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyVerseModelImplCopyWith<_$DailyVerseModelImpl> get copyWith =>
      __$$DailyVerseModelImplCopyWithImpl<_$DailyVerseModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyVerseModelImplToJson(
      this,
    );
  }
}

abstract class _DailyVerseModel extends DailyVerseModel {
  const factory _DailyVerseModel(
      {required final int id,
      @JsonKey(name: 'verse_reference') required final String verseReference,
      required final String content,
      final String? date}) = _$DailyVerseModelImpl;
  const _DailyVerseModel._() : super._();

  factory _DailyVerseModel.fromJson(Map<String, dynamic> json) =
      _$DailyVerseModelImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'verse_reference')
  String get verseReference;
  @override
  String get content;
  @override
  String? get date;

  /// Create a copy of DailyVerseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyVerseModelImplCopyWith<_$DailyVerseModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
