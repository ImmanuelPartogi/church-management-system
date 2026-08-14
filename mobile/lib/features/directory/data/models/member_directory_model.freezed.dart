// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'member_directory_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MemberDirectoryModel _$MemberDirectoryModelFromJson(Map<String, dynamic> json) {
  return _MemberDirectoryModel.fromJson(json);
}

/// @nodoc
mixin _$MemberDirectoryModel {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'membership_number')
  String? get membershipNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_name')
  String get fullName => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'masked_phone')
  String? get maskedPhone => throw _privateConstructorUsedError;
  @JsonKey(name: 'has_app_account')
  bool get hasAppAccount => throw _privateConstructorUsedError;

  /// Serializes this MemberDirectoryModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MemberDirectoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MemberDirectoryModelCopyWith<MemberDirectoryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MemberDirectoryModelCopyWith<$Res> {
  factory $MemberDirectoryModelCopyWith(MemberDirectoryModel value,
          $Res Function(MemberDirectoryModel) then) =
      _$MemberDirectoryModelCopyWithImpl<$Res, MemberDirectoryModel>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'membership_number') String? membershipNumber,
      @JsonKey(name: 'full_name') String fullName,
      String? gender,
      String? status,
      @JsonKey(name: 'masked_phone') String? maskedPhone,
      @JsonKey(name: 'has_app_account') bool hasAppAccount});
}

/// @nodoc
class _$MemberDirectoryModelCopyWithImpl<$Res,
        $Val extends MemberDirectoryModel>
    implements $MemberDirectoryModelCopyWith<$Res> {
  _$MemberDirectoryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MemberDirectoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? membershipNumber = freezed,
    Object? fullName = null,
    Object? gender = freezed,
    Object? status = freezed,
    Object? maskedPhone = freezed,
    Object? hasAppAccount = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      membershipNumber: freezed == membershipNumber
          ? _value.membershipNumber
          : membershipNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      maskedPhone: freezed == maskedPhone
          ? _value.maskedPhone
          : maskedPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      hasAppAccount: null == hasAppAccount
          ? _value.hasAppAccount
          : hasAppAccount // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MemberDirectoryModelImplCopyWith<$Res>
    implements $MemberDirectoryModelCopyWith<$Res> {
  factory _$$MemberDirectoryModelImplCopyWith(_$MemberDirectoryModelImpl value,
          $Res Function(_$MemberDirectoryModelImpl) then) =
      __$$MemberDirectoryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'membership_number') String? membershipNumber,
      @JsonKey(name: 'full_name') String fullName,
      String? gender,
      String? status,
      @JsonKey(name: 'masked_phone') String? maskedPhone,
      @JsonKey(name: 'has_app_account') bool hasAppAccount});
}

/// @nodoc
class __$$MemberDirectoryModelImplCopyWithImpl<$Res>
    extends _$MemberDirectoryModelCopyWithImpl<$Res, _$MemberDirectoryModelImpl>
    implements _$$MemberDirectoryModelImplCopyWith<$Res> {
  __$$MemberDirectoryModelImplCopyWithImpl(_$MemberDirectoryModelImpl _value,
      $Res Function(_$MemberDirectoryModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of MemberDirectoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? membershipNumber = freezed,
    Object? fullName = null,
    Object? gender = freezed,
    Object? status = freezed,
    Object? maskedPhone = freezed,
    Object? hasAppAccount = null,
  }) {
    return _then(_$MemberDirectoryModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      membershipNumber: freezed == membershipNumber
          ? _value.membershipNumber
          : membershipNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      maskedPhone: freezed == maskedPhone
          ? _value.maskedPhone
          : maskedPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      hasAppAccount: null == hasAppAccount
          ? _value.hasAppAccount
          : hasAppAccount // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MemberDirectoryModelImpl extends _MemberDirectoryModel {
  const _$MemberDirectoryModelImpl(
      {required this.id,
      @JsonKey(name: 'membership_number') this.membershipNumber,
      @JsonKey(name: 'full_name') required this.fullName,
      this.gender,
      this.status,
      @JsonKey(name: 'masked_phone') this.maskedPhone,
      @JsonKey(name: 'has_app_account') this.hasAppAccount = false})
      : super._();

  factory _$MemberDirectoryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MemberDirectoryModelImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'membership_number')
  final String? membershipNumber;
  @override
  @JsonKey(name: 'full_name')
  final String fullName;
  @override
  final String? gender;
  @override
  final String? status;
  @override
  @JsonKey(name: 'masked_phone')
  final String? maskedPhone;
  @override
  @JsonKey(name: 'has_app_account')
  final bool hasAppAccount;

  @override
  String toString() {
    return 'MemberDirectoryModel(id: $id, membershipNumber: $membershipNumber, fullName: $fullName, gender: $gender, status: $status, maskedPhone: $maskedPhone, hasAppAccount: $hasAppAccount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MemberDirectoryModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.membershipNumber, membershipNumber) ||
                other.membershipNumber == membershipNumber) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.maskedPhone, maskedPhone) ||
                other.maskedPhone == maskedPhone) &&
            (identical(other.hasAppAccount, hasAppAccount) ||
                other.hasAppAccount == hasAppAccount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, membershipNumber, fullName,
      gender, status, maskedPhone, hasAppAccount);

  /// Create a copy of MemberDirectoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MemberDirectoryModelImplCopyWith<_$MemberDirectoryModelImpl>
      get copyWith =>
          __$$MemberDirectoryModelImplCopyWithImpl<_$MemberDirectoryModelImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MemberDirectoryModelImplToJson(
      this,
    );
  }
}

abstract class _MemberDirectoryModel extends MemberDirectoryModel {
  const factory _MemberDirectoryModel(
          {required final int id,
          @JsonKey(name: 'membership_number') final String? membershipNumber,
          @JsonKey(name: 'full_name') required final String fullName,
          final String? gender,
          final String? status,
          @JsonKey(name: 'masked_phone') final String? maskedPhone,
          @JsonKey(name: 'has_app_account') final bool hasAppAccount}) =
      _$MemberDirectoryModelImpl;
  const _MemberDirectoryModel._() : super._();

  factory _MemberDirectoryModel.fromJson(Map<String, dynamic> json) =
      _$MemberDirectoryModelImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'membership_number')
  String? get membershipNumber;
  @override
  @JsonKey(name: 'full_name')
  String get fullName;
  @override
  String? get gender;
  @override
  String? get status;
  @override
  @JsonKey(name: 'masked_phone')
  String? get maskedPhone;
  @override
  @JsonKey(name: 'has_app_account')
  bool get hasAppAccount;

  /// Create a copy of MemberDirectoryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MemberDirectoryModelImplCopyWith<_$MemberDirectoryModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
