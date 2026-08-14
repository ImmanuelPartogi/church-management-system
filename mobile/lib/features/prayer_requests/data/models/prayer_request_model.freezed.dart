// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prayer_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PrayerRequestModel _$PrayerRequestModelFromJson(Map<String, dynamic> json) {
  return _PrayerRequestModel.fromJson(json);
}

/// @nodoc
mixin _$PrayerRequestModel {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  int get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'member_id')
  int? get memberId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_private')
  bool get isPrivate => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'follow_up_notes')
  String? get followUpNotes => throw _privateConstructorUsedError;
  @JsonKey(name: 'followed_up_at')
  String? get followedUpAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this PrayerRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PrayerRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PrayerRequestModelCopyWith<PrayerRequestModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrayerRequestModelCopyWith<$Res> {
  factory $PrayerRequestModelCopyWith(
          PrayerRequestModel value, $Res Function(PrayerRequestModel) then) =
      _$PrayerRequestModelCopyWithImpl<$Res, PrayerRequestModel>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'user_id') int userId,
      @JsonKey(name: 'member_id') int? memberId,
      String title,
      String content,
      String? category,
      @JsonKey(name: 'is_private') bool isPrivate,
      String status,
      @JsonKey(name: 'follow_up_notes') String? followUpNotes,
      @JsonKey(name: 'followed_up_at') String? followedUpAt,
      @JsonKey(name: 'created_at') String createdAt,
      @JsonKey(name: 'updated_at') String updatedAt});
}

/// @nodoc
class _$PrayerRequestModelCopyWithImpl<$Res, $Val extends PrayerRequestModel>
    implements $PrayerRequestModelCopyWith<$Res> {
  _$PrayerRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PrayerRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? memberId = freezed,
    Object? title = null,
    Object? content = null,
    Object? category = freezed,
    Object? isPrivate = null,
    Object? status = null,
    Object? followUpNotes = freezed,
    Object? followedUpAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      memberId: freezed == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as int?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      isPrivate: null == isPrivate
          ? _value.isPrivate
          : isPrivate // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      followUpNotes: freezed == followUpNotes
          ? _value.followUpNotes
          : followUpNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      followedUpAt: freezed == followedUpAt
          ? _value.followedUpAt
          : followedUpAt // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PrayerRequestModelImplCopyWith<$Res>
    implements $PrayerRequestModelCopyWith<$Res> {
  factory _$$PrayerRequestModelImplCopyWith(_$PrayerRequestModelImpl value,
          $Res Function(_$PrayerRequestModelImpl) then) =
      __$$PrayerRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'user_id') int userId,
      @JsonKey(name: 'member_id') int? memberId,
      String title,
      String content,
      String? category,
      @JsonKey(name: 'is_private') bool isPrivate,
      String status,
      @JsonKey(name: 'follow_up_notes') String? followUpNotes,
      @JsonKey(name: 'followed_up_at') String? followedUpAt,
      @JsonKey(name: 'created_at') String createdAt,
      @JsonKey(name: 'updated_at') String updatedAt});
}

/// @nodoc
class __$$PrayerRequestModelImplCopyWithImpl<$Res>
    extends _$PrayerRequestModelCopyWithImpl<$Res, _$PrayerRequestModelImpl>
    implements _$$PrayerRequestModelImplCopyWith<$Res> {
  __$$PrayerRequestModelImplCopyWithImpl(_$PrayerRequestModelImpl _value,
      $Res Function(_$PrayerRequestModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of PrayerRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? memberId = freezed,
    Object? title = null,
    Object? content = null,
    Object? category = freezed,
    Object? isPrivate = null,
    Object? status = null,
    Object? followUpNotes = freezed,
    Object? followedUpAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$PrayerRequestModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      memberId: freezed == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as int?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      isPrivate: null == isPrivate
          ? _value.isPrivate
          : isPrivate // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      followUpNotes: freezed == followUpNotes
          ? _value.followUpNotes
          : followUpNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      followedUpAt: freezed == followedUpAt
          ? _value.followedUpAt
          : followedUpAt // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PrayerRequestModelImpl extends _PrayerRequestModel {
  const _$PrayerRequestModelImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'member_id') this.memberId,
      required this.title,
      required this.content,
      this.category,
      @JsonKey(name: 'is_private') required this.isPrivate,
      required this.status,
      @JsonKey(name: 'follow_up_notes') this.followUpNotes,
      @JsonKey(name: 'followed_up_at') this.followedUpAt,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt})
      : super._();

  factory _$PrayerRequestModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PrayerRequestModelImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'user_id')
  final int userId;
  @override
  @JsonKey(name: 'member_id')
  final int? memberId;
  @override
  final String title;
  @override
  final String content;
  @override
  final String? category;
  @override
  @JsonKey(name: 'is_private')
  final bool isPrivate;
  @override
  final String status;
  @override
  @JsonKey(name: 'follow_up_notes')
  final String? followUpNotes;
  @override
  @JsonKey(name: 'followed_up_at')
  final String? followedUpAt;
  @override
  @JsonKey(name: 'created_at')
  final String createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  @override
  String toString() {
    return 'PrayerRequestModel(id: $id, userId: $userId, memberId: $memberId, title: $title, content: $content, category: $category, isPrivate: $isPrivate, status: $status, followUpNotes: $followUpNotes, followedUpAt: $followedUpAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PrayerRequestModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.memberId, memberId) ||
                other.memberId == memberId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.isPrivate, isPrivate) ||
                other.isPrivate == isPrivate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.followUpNotes, followUpNotes) ||
                other.followUpNotes == followUpNotes) &&
            (identical(other.followedUpAt, followedUpAt) ||
                other.followedUpAt == followedUpAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      memberId,
      title,
      content,
      category,
      isPrivate,
      status,
      followUpNotes,
      followedUpAt,
      createdAt,
      updatedAt);

  /// Create a copy of PrayerRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PrayerRequestModelImplCopyWith<_$PrayerRequestModelImpl> get copyWith =>
      __$$PrayerRequestModelImplCopyWithImpl<_$PrayerRequestModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PrayerRequestModelImplToJson(
      this,
    );
  }
}

abstract class _PrayerRequestModel extends PrayerRequestModel {
  const factory _PrayerRequestModel(
          {required final int id,
          @JsonKey(name: 'user_id') required final int userId,
          @JsonKey(name: 'member_id') final int? memberId,
          required final String title,
          required final String content,
          final String? category,
          @JsonKey(name: 'is_private') required final bool isPrivate,
          required final String status,
          @JsonKey(name: 'follow_up_notes') final String? followUpNotes,
          @JsonKey(name: 'followed_up_at') final String? followedUpAt,
          @JsonKey(name: 'created_at') required final String createdAt,
          @JsonKey(name: 'updated_at') required final String updatedAt}) =
      _$PrayerRequestModelImpl;
  const _PrayerRequestModel._() : super._();

  factory _PrayerRequestModel.fromJson(Map<String, dynamic> json) =
      _$PrayerRequestModelImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'user_id')
  int get userId;
  @override
  @JsonKey(name: 'member_id')
  int? get memberId;
  @override
  String get title;
  @override
  String get content;
  @override
  String? get category;
  @override
  @JsonKey(name: 'is_private')
  bool get isPrivate;
  @override
  String get status;
  @override
  @JsonKey(name: 'follow_up_notes')
  String? get followUpNotes;
  @override
  @JsonKey(name: 'followed_up_at')
  String? get followedUpAt;
  @override
  @JsonKey(name: 'created_at')
  String get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String get updatedAt;

  /// Create a copy of PrayerRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PrayerRequestModelImplCopyWith<_$PrayerRequestModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
