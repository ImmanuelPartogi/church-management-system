// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'worship_schedule_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WorshipScheduleModel _$WorshipScheduleModelFromJson(Map<String, dynamic> json) {
  return _WorshipScheduleModel.fromJson(json);
}

/// @nodoc
mixin _$WorshipScheduleModel {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String get day => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_time')
  String get startTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_time')
  String? get endTime => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  bool get active => throw _privateConstructorUsedError;

  /// Serializes this WorshipScheduleModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorshipScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorshipScheduleModelCopyWith<WorshipScheduleModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorshipScheduleModelCopyWith<$Res> {
  factory $WorshipScheduleModelCopyWith(WorshipScheduleModel value,
          $Res Function(WorshipScheduleModel) then) =
      _$WorshipScheduleModelCopyWithImpl<$Res, WorshipScheduleModel>;
  @useResult
  $Res call(
      {int id,
      String title,
      String? description,
      String day,
      @JsonKey(name: 'start_time') String startTime,
      @JsonKey(name: 'end_time') String? endTime,
      String? location,
      bool active});
}

/// @nodoc
class _$WorshipScheduleModelCopyWithImpl<$Res,
        $Val extends WorshipScheduleModel>
    implements $WorshipScheduleModelCopyWith<$Res> {
  _$WorshipScheduleModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorshipScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? day = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? location = freezed,
    Object? active = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      day: null == day
          ? _value.day
          : day // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorshipScheduleModelImplCopyWith<$Res>
    implements $WorshipScheduleModelCopyWith<$Res> {
  factory _$$WorshipScheduleModelImplCopyWith(_$WorshipScheduleModelImpl value,
          $Res Function(_$WorshipScheduleModelImpl) then) =
      __$$WorshipScheduleModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String title,
      String? description,
      String day,
      @JsonKey(name: 'start_time') String startTime,
      @JsonKey(name: 'end_time') String? endTime,
      String? location,
      bool active});
}

/// @nodoc
class __$$WorshipScheduleModelImplCopyWithImpl<$Res>
    extends _$WorshipScheduleModelCopyWithImpl<$Res, _$WorshipScheduleModelImpl>
    implements _$$WorshipScheduleModelImplCopyWith<$Res> {
  __$$WorshipScheduleModelImplCopyWithImpl(_$WorshipScheduleModelImpl _value,
      $Res Function(_$WorshipScheduleModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of WorshipScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? day = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? location = freezed,
    Object? active = null,
  }) {
    return _then(_$WorshipScheduleModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      day: null == day
          ? _value.day
          : day // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorshipScheduleModelImpl extends _WorshipScheduleModel {
  const _$WorshipScheduleModelImpl(
      {required this.id,
      required this.title,
      this.description,
      required this.day,
      @JsonKey(name: 'start_time') required this.startTime,
      @JsonKey(name: 'end_time') this.endTime,
      this.location,
      required this.active})
      : super._();

  factory _$WorshipScheduleModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorshipScheduleModelImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final String? description;
  @override
  final String day;
  @override
  @JsonKey(name: 'start_time')
  final String startTime;
  @override
  @JsonKey(name: 'end_time')
  final String? endTime;
  @override
  final String? location;
  @override
  final bool active;

  @override
  String toString() {
    return 'WorshipScheduleModel(id: $id, title: $title, description: $description, day: $day, startTime: $startTime, endTime: $endTime, location: $location, active: $active)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorshipScheduleModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.day, day) || other.day == day) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.active, active) || other.active == active));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, description, day,
      startTime, endTime, location, active);

  /// Create a copy of WorshipScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorshipScheduleModelImplCopyWith<_$WorshipScheduleModelImpl>
      get copyWith =>
          __$$WorshipScheduleModelImplCopyWithImpl<_$WorshipScheduleModelImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorshipScheduleModelImplToJson(
      this,
    );
  }
}

abstract class _WorshipScheduleModel extends WorshipScheduleModel {
  const factory _WorshipScheduleModel(
      {required final int id,
      required final String title,
      final String? description,
      required final String day,
      @JsonKey(name: 'start_time') required final String startTime,
      @JsonKey(name: 'end_time') final String? endTime,
      final String? location,
      required final bool active}) = _$WorshipScheduleModelImpl;
  const _WorshipScheduleModel._() : super._();

  factory _WorshipScheduleModel.fromJson(Map<String, dynamic> json) =
      _$WorshipScheduleModelImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  String? get description;
  @override
  String get day;
  @override
  @JsonKey(name: 'start_time')
  String get startTime;
  @override
  @JsonKey(name: 'end_time')
  String? get endTime;
  @override
  String? get location;
  @override
  bool get active;

  /// Create a copy of WorshipScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorshipScheduleModelImplCopyWith<_$WorshipScheduleModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
