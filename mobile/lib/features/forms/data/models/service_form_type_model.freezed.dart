// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service_form_type_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ServiceFormTypeModel _$ServiceFormTypeModelFromJson(Map<String, dynamic> json) {
  return _ServiceFormTypeModel.fromJson(json);
}

/// @nodoc
mixin _$ServiceFormTypeModel {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'fee_amount')
  num get feeAmount => throw _privateConstructorUsedError;
  bool get active => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ServiceFormTypeModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ServiceFormTypeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ServiceFormTypeModelCopyWith<ServiceFormTypeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServiceFormTypeModelCopyWith<$Res> {
  factory $ServiceFormTypeModelCopyWith(ServiceFormTypeModel value,
          $Res Function(ServiceFormTypeModel) then) =
      _$ServiceFormTypeModelCopyWithImpl<$Res, ServiceFormTypeModel>;
  @useResult
  $Res call(
      {int id,
      String name,
      String slug,
      String? description,
      @JsonKey(name: 'fee_amount') num feeAmount,
      bool active,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt});
}

/// @nodoc
class _$ServiceFormTypeModelCopyWithImpl<$Res,
        $Val extends ServiceFormTypeModel>
    implements $ServiceFormTypeModelCopyWith<$Res> {
  _$ServiceFormTypeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ServiceFormTypeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? slug = null,
    Object? description = freezed,
    Object? feeAmount = null,
    Object? active = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
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
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      feeAmount: null == feeAmount
          ? _value.feeAmount
          : feeAmount // ignore: cast_nullable_to_non_nullable
              as num,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
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
abstract class _$$ServiceFormTypeModelImplCopyWith<$Res>
    implements $ServiceFormTypeModelCopyWith<$Res> {
  factory _$$ServiceFormTypeModelImplCopyWith(_$ServiceFormTypeModelImpl value,
          $Res Function(_$ServiceFormTypeModelImpl) then) =
      __$$ServiceFormTypeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String slug,
      String? description,
      @JsonKey(name: 'fee_amount') num feeAmount,
      bool active,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt});
}

/// @nodoc
class __$$ServiceFormTypeModelImplCopyWithImpl<$Res>
    extends _$ServiceFormTypeModelCopyWithImpl<$Res, _$ServiceFormTypeModelImpl>
    implements _$$ServiceFormTypeModelImplCopyWith<$Res> {
  __$$ServiceFormTypeModelImplCopyWithImpl(_$ServiceFormTypeModelImpl _value,
      $Res Function(_$ServiceFormTypeModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ServiceFormTypeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? slug = null,
    Object? description = freezed,
    Object? feeAmount = null,
    Object? active = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$ServiceFormTypeModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      feeAmount: null == feeAmount
          ? _value.feeAmount
          : feeAmount // ignore: cast_nullable_to_non_nullable
              as num,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
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
class _$ServiceFormTypeModelImpl extends _ServiceFormTypeModel {
  const _$ServiceFormTypeModelImpl(
      {required this.id,
      required this.name,
      required this.slug,
      this.description,
      @JsonKey(name: 'fee_amount') required this.feeAmount,
      required this.active,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : super._();

  factory _$ServiceFormTypeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServiceFormTypeModelImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String slug;
  @override
  final String? description;
  @override
  @JsonKey(name: 'fee_amount')
  final num feeAmount;
  @override
  final bool active;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @override
  String toString() {
    return 'ServiceFormTypeModel(id: $id, name: $name, slug: $slug, description: $description, feeAmount: $feeAmount, active: $active, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServiceFormTypeModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.feeAmount, feeAmount) ||
                other.feeAmount == feeAmount) &&
            (identical(other.active, active) || other.active == active) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, slug, description,
      feeAmount, active, createdAt, updatedAt);

  /// Create a copy of ServiceFormTypeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServiceFormTypeModelImplCopyWith<_$ServiceFormTypeModelImpl>
      get copyWith =>
          __$$ServiceFormTypeModelImplCopyWithImpl<_$ServiceFormTypeModelImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ServiceFormTypeModelImplToJson(
      this,
    );
  }
}

abstract class _ServiceFormTypeModel extends ServiceFormTypeModel {
  const factory _ServiceFormTypeModel(
          {required final int id,
          required final String name,
          required final String slug,
          final String? description,
          @JsonKey(name: 'fee_amount') required final num feeAmount,
          required final bool active,
          @JsonKey(name: 'created_at') final String? createdAt,
          @JsonKey(name: 'updated_at') final String? updatedAt}) =
      _$ServiceFormTypeModelImpl;
  const _ServiceFormTypeModel._() : super._();

  factory _ServiceFormTypeModel.fromJson(Map<String, dynamic> json) =
      _$ServiceFormTypeModelImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get slug;
  @override
  String? get description;
  @override
  @JsonKey(name: 'fee_amount')
  num get feeAmount;
  @override
  bool get active;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String? get updatedAt;

  /// Create a copy of ServiceFormTypeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServiceFormTypeModelImplCopyWith<_$ServiceFormTypeModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
