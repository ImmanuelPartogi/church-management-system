// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chart_of_account_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChartOfAccountModel _$ChartOfAccountModelFromJson(Map<String, dynamic> json) {
  return _ChartOfAccountModel.fromJson(json);
}

/// @nodoc
mixin _$ChartOfAccountModel {
  int get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this ChartOfAccountModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChartOfAccountModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChartOfAccountModelCopyWith<ChartOfAccountModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChartOfAccountModelCopyWith<$Res> {
  factory $ChartOfAccountModelCopyWith(
          ChartOfAccountModel value, $Res Function(ChartOfAccountModel) then) =
      _$ChartOfAccountModelCopyWithImpl<$Res, ChartOfAccountModel>;
  @useResult
  $Res call(
      {int id,
      String code,
      String name,
      String type,
      String? description,
      @JsonKey(name: 'is_active') bool isActive});
}

/// @nodoc
class _$ChartOfAccountModelCopyWithImpl<$Res, $Val extends ChartOfAccountModel>
    implements $ChartOfAccountModelCopyWith<$Res> {
  _$ChartOfAccountModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChartOfAccountModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? type = null,
    Object? description = freezed,
    Object? isActive = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChartOfAccountModelImplCopyWith<$Res>
    implements $ChartOfAccountModelCopyWith<$Res> {
  factory _$$ChartOfAccountModelImplCopyWith(_$ChartOfAccountModelImpl value,
          $Res Function(_$ChartOfAccountModelImpl) then) =
      __$$ChartOfAccountModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String code,
      String name,
      String type,
      String? description,
      @JsonKey(name: 'is_active') bool isActive});
}

/// @nodoc
class __$$ChartOfAccountModelImplCopyWithImpl<$Res>
    extends _$ChartOfAccountModelCopyWithImpl<$Res, _$ChartOfAccountModelImpl>
    implements _$$ChartOfAccountModelImplCopyWith<$Res> {
  __$$ChartOfAccountModelImplCopyWithImpl(_$ChartOfAccountModelImpl _value,
      $Res Function(_$ChartOfAccountModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChartOfAccountModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? type = null,
    Object? description = freezed,
    Object? isActive = null,
  }) {
    return _then(_$ChartOfAccountModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChartOfAccountModelImpl extends _ChartOfAccountModel {
  const _$ChartOfAccountModelImpl(
      {required this.id,
      required this.code,
      required this.name,
      required this.type,
      this.description,
      @JsonKey(name: 'is_active') required this.isActive})
      : super._();

  factory _$ChartOfAccountModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChartOfAccountModelImplFromJson(json);

  @override
  final int id;
  @override
  final String code;
  @override
  final String name;
  @override
  final String type;
  @override
  final String? description;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;

  @override
  String toString() {
    return 'ChartOfAccountModel(id: $id, code: $code, name: $name, type: $type, description: $description, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChartOfAccountModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, code, name, type, description, isActive);

  /// Create a copy of ChartOfAccountModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChartOfAccountModelImplCopyWith<_$ChartOfAccountModelImpl> get copyWith =>
      __$$ChartOfAccountModelImplCopyWithImpl<_$ChartOfAccountModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChartOfAccountModelImplToJson(
      this,
    );
  }
}

abstract class _ChartOfAccountModel extends ChartOfAccountModel {
  const factory _ChartOfAccountModel(
          {required final int id,
          required final String code,
          required final String name,
          required final String type,
          final String? description,
          @JsonKey(name: 'is_active') required final bool isActive}) =
      _$ChartOfAccountModelImpl;
  const _ChartOfAccountModel._() : super._();

  factory _ChartOfAccountModel.fromJson(Map<String, dynamic> json) =
      _$ChartOfAccountModelImpl.fromJson;

  @override
  int get id;
  @override
  String get code;
  @override
  String get name;
  @override
  String get type;
  @override
  String? get description;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;

  /// Create a copy of ChartOfAccountModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChartOfAccountModelImplCopyWith<_$ChartOfAccountModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
