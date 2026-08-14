// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'member_detail_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MemberDetailModel _$MemberDetailModelFromJson(Map<String, dynamic> json) {
  return _MemberDetailModel.fromJson(json);
}

/// @nodoc
mixin _$MemberDetailModel {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'membership_number')
  String? get membershipNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_name')
  String get fullName => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  @JsonKey(name: 'birth_date')
  String? get birthDate => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  @JsonKey(name: 'baptism_date')
  String? get baptismDate => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'has_app_account')
  bool get hasAppAccount => throw _privateConstructorUsedError;

  /// Serializes this MemberDetailModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MemberDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MemberDetailModelCopyWith<MemberDetailModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MemberDetailModelCopyWith<$Res> {
  factory $MemberDetailModelCopyWith(
          MemberDetailModel value, $Res Function(MemberDetailModel) then) =
      _$MemberDetailModelCopyWithImpl<$Res, MemberDetailModel>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'membership_number') String? membershipNumber,
      @JsonKey(name: 'full_name') String fullName,
      String? gender,
      @JsonKey(name: 'birth_date') String? birthDate,
      String? phone,
      String? email,
      String? address,
      @JsonKey(name: 'baptism_date') String? baptismDate,
      String? status,
      @JsonKey(name: 'has_app_account') bool hasAppAccount});
}

/// @nodoc
class _$MemberDetailModelCopyWithImpl<$Res, $Val extends MemberDetailModel>
    implements $MemberDetailModelCopyWith<$Res> {
  _$MemberDetailModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MemberDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? membershipNumber = freezed,
    Object? fullName = null,
    Object? gender = freezed,
    Object? birthDate = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? address = freezed,
    Object? baptismDate = freezed,
    Object? status = freezed,
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
      birthDate: freezed == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      baptismDate: freezed == baptismDate
          ? _value.baptismDate
          : baptismDate // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      hasAppAccount: null == hasAppAccount
          ? _value.hasAppAccount
          : hasAppAccount // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MemberDetailModelImplCopyWith<$Res>
    implements $MemberDetailModelCopyWith<$Res> {
  factory _$$MemberDetailModelImplCopyWith(_$MemberDetailModelImpl value,
          $Res Function(_$MemberDetailModelImpl) then) =
      __$$MemberDetailModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'membership_number') String? membershipNumber,
      @JsonKey(name: 'full_name') String fullName,
      String? gender,
      @JsonKey(name: 'birth_date') String? birthDate,
      String? phone,
      String? email,
      String? address,
      @JsonKey(name: 'baptism_date') String? baptismDate,
      String? status,
      @JsonKey(name: 'has_app_account') bool hasAppAccount});
}

/// @nodoc
class __$$MemberDetailModelImplCopyWithImpl<$Res>
    extends _$MemberDetailModelCopyWithImpl<$Res, _$MemberDetailModelImpl>
    implements _$$MemberDetailModelImplCopyWith<$Res> {
  __$$MemberDetailModelImplCopyWithImpl(_$MemberDetailModelImpl _value,
      $Res Function(_$MemberDetailModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of MemberDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? membershipNumber = freezed,
    Object? fullName = null,
    Object? gender = freezed,
    Object? birthDate = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? address = freezed,
    Object? baptismDate = freezed,
    Object? status = freezed,
    Object? hasAppAccount = null,
  }) {
    return _then(_$MemberDetailModelImpl(
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
      birthDate: freezed == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      baptismDate: freezed == baptismDate
          ? _value.baptismDate
          : baptismDate // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
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
class _$MemberDetailModelImpl extends _MemberDetailModel {
  const _$MemberDetailModelImpl(
      {required this.id,
      @JsonKey(name: 'membership_number') this.membershipNumber,
      @JsonKey(name: 'full_name') required this.fullName,
      this.gender,
      @JsonKey(name: 'birth_date') this.birthDate,
      this.phone,
      this.email,
      this.address,
      @JsonKey(name: 'baptism_date') this.baptismDate,
      this.status,
      @JsonKey(name: 'has_app_account') this.hasAppAccount = false})
      : super._();

  factory _$MemberDetailModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MemberDetailModelImplFromJson(json);

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
  @JsonKey(name: 'birth_date')
  final String? birthDate;
  @override
  final String? phone;
  @override
  final String? email;
  @override
  final String? address;
  @override
  @JsonKey(name: 'baptism_date')
  final String? baptismDate;
  @override
  final String? status;
  @override
  @JsonKey(name: 'has_app_account')
  final bool hasAppAccount;

  @override
  String toString() {
    return 'MemberDetailModel(id: $id, membershipNumber: $membershipNumber, fullName: $fullName, gender: $gender, birthDate: $birthDate, phone: $phone, email: $email, address: $address, baptismDate: $baptismDate, status: $status, hasAppAccount: $hasAppAccount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MemberDetailModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.membershipNumber, membershipNumber) ||
                other.membershipNumber == membershipNumber) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.birthDate, birthDate) ||
                other.birthDate == birthDate) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.baptismDate, baptismDate) ||
                other.baptismDate == baptismDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.hasAppAccount, hasAppAccount) ||
                other.hasAppAccount == hasAppAccount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      membershipNumber,
      fullName,
      gender,
      birthDate,
      phone,
      email,
      address,
      baptismDate,
      status,
      hasAppAccount);

  /// Create a copy of MemberDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MemberDetailModelImplCopyWith<_$MemberDetailModelImpl> get copyWith =>
      __$$MemberDetailModelImplCopyWithImpl<_$MemberDetailModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MemberDetailModelImplToJson(
      this,
    );
  }
}

abstract class _MemberDetailModel extends MemberDetailModel {
  const factory _MemberDetailModel(
          {required final int id,
          @JsonKey(name: 'membership_number') final String? membershipNumber,
          @JsonKey(name: 'full_name') required final String fullName,
          final String? gender,
          @JsonKey(name: 'birth_date') final String? birthDate,
          final String? phone,
          final String? email,
          final String? address,
          @JsonKey(name: 'baptism_date') final String? baptismDate,
          final String? status,
          @JsonKey(name: 'has_app_account') final bool hasAppAccount}) =
      _$MemberDetailModelImpl;
  const _MemberDetailModel._() : super._();

  factory _MemberDetailModel.fromJson(Map<String, dynamic> json) =
      _$MemberDetailModelImpl.fromJson;

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
  @JsonKey(name: 'birth_date')
  String? get birthDate;
  @override
  String? get phone;
  @override
  String? get email;
  @override
  String? get address;
  @override
  @JsonKey(name: 'baptism_date')
  String? get baptismDate;
  @override
  String? get status;
  @override
  @JsonKey(name: 'has_app_account')
  bool get hasAppAccount;

  /// Create a copy of MemberDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MemberDetailModelImplCopyWith<_$MemberDetailModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
