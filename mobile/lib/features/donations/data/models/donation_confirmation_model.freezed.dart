// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'donation_confirmation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DonationConfirmationModel _$DonationConfirmationModelFromJson(
    Map<String, dynamic> json) {
  return _DonationConfirmationModel.fromJson(json);
}

/// @nodoc
mixin _$DonationConfirmationModel {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'donation_number')
  String get donationNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  int get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'member_id')
  int? get memberId => throw _privateConstructorUsedError;
  ChartOfAccountModel? get category => throw _privateConstructorUsedError;
  num get amount => throw _privateConstructorUsedError;
  @JsonKey(name: 'transfer_date')
  String get transferDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'sender_bank')
  String get senderBank => throw _privateConstructorUsedError;
  @JsonKey(name: 'depositor_phone')
  String? get depositorPhone => throw _privateConstructorUsedError;
  @JsonKey(name: 'proof_file_url')
  String? get proofFileUrl => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'rejection_reason')
  String? get rejectionReason => throw _privateConstructorUsedError;
  @JsonKey(name: 'reviewed_at')
  String? get reviewedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this DonationConfirmationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DonationConfirmationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DonationConfirmationModelCopyWith<DonationConfirmationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DonationConfirmationModelCopyWith<$Res> {
  factory $DonationConfirmationModelCopyWith(DonationConfirmationModel value,
          $Res Function(DonationConfirmationModel) then) =
      _$DonationConfirmationModelCopyWithImpl<$Res, DonationConfirmationModel>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'donation_number') String donationNumber,
      @JsonKey(name: 'user_id') int userId,
      @JsonKey(name: 'member_id') int? memberId,
      ChartOfAccountModel? category,
      num amount,
      @JsonKey(name: 'transfer_date') String transferDate,
      @JsonKey(name: 'sender_bank') String senderBank,
      @JsonKey(name: 'depositor_phone') String? depositorPhone,
      @JsonKey(name: 'proof_file_url') String? proofFileUrl,
      String status,
      String? notes,
      @JsonKey(name: 'rejection_reason') String? rejectionReason,
      @JsonKey(name: 'reviewed_at') String? reviewedAt,
      @JsonKey(name: 'created_at') String createdAt,
      @JsonKey(name: 'updated_at') String updatedAt});

  $ChartOfAccountModelCopyWith<$Res>? get category;
}

/// @nodoc
class _$DonationConfirmationModelCopyWithImpl<$Res,
        $Val extends DonationConfirmationModel>
    implements $DonationConfirmationModelCopyWith<$Res> {
  _$DonationConfirmationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DonationConfirmationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? donationNumber = null,
    Object? userId = null,
    Object? memberId = freezed,
    Object? category = freezed,
    Object? amount = null,
    Object? transferDate = null,
    Object? senderBank = null,
    Object? depositorPhone = freezed,
    Object? proofFileUrl = freezed,
    Object? status = null,
    Object? notes = freezed,
    Object? rejectionReason = freezed,
    Object? reviewedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      donationNumber: null == donationNumber
          ? _value.donationNumber
          : donationNumber // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      memberId: freezed == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as int?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ChartOfAccountModel?,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as num,
      transferDate: null == transferDate
          ? _value.transferDate
          : transferDate // ignore: cast_nullable_to_non_nullable
              as String,
      senderBank: null == senderBank
          ? _value.senderBank
          : senderBank // ignore: cast_nullable_to_non_nullable
              as String,
      depositorPhone: freezed == depositorPhone
          ? _value.depositorPhone
          : depositorPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      proofFileUrl: freezed == proofFileUrl
          ? _value.proofFileUrl
          : proofFileUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      rejectionReason: freezed == rejectionReason
          ? _value.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
      reviewedAt: freezed == reviewedAt
          ? _value.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
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

  /// Create a copy of DonationConfirmationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChartOfAccountModelCopyWith<$Res>? get category {
    if (_value.category == null) {
      return null;
    }

    return $ChartOfAccountModelCopyWith<$Res>(_value.category!, (value) {
      return _then(_value.copyWith(category: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DonationConfirmationModelImplCopyWith<$Res>
    implements $DonationConfirmationModelCopyWith<$Res> {
  factory _$$DonationConfirmationModelImplCopyWith(
          _$DonationConfirmationModelImpl value,
          $Res Function(_$DonationConfirmationModelImpl) then) =
      __$$DonationConfirmationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'donation_number') String donationNumber,
      @JsonKey(name: 'user_id') int userId,
      @JsonKey(name: 'member_id') int? memberId,
      ChartOfAccountModel? category,
      num amount,
      @JsonKey(name: 'transfer_date') String transferDate,
      @JsonKey(name: 'sender_bank') String senderBank,
      @JsonKey(name: 'depositor_phone') String? depositorPhone,
      @JsonKey(name: 'proof_file_url') String? proofFileUrl,
      String status,
      String? notes,
      @JsonKey(name: 'rejection_reason') String? rejectionReason,
      @JsonKey(name: 'reviewed_at') String? reviewedAt,
      @JsonKey(name: 'created_at') String createdAt,
      @JsonKey(name: 'updated_at') String updatedAt});

  @override
  $ChartOfAccountModelCopyWith<$Res>? get category;
}

/// @nodoc
class __$$DonationConfirmationModelImplCopyWithImpl<$Res>
    extends _$DonationConfirmationModelCopyWithImpl<$Res,
        _$DonationConfirmationModelImpl>
    implements _$$DonationConfirmationModelImplCopyWith<$Res> {
  __$$DonationConfirmationModelImplCopyWithImpl(
      _$DonationConfirmationModelImpl _value,
      $Res Function(_$DonationConfirmationModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of DonationConfirmationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? donationNumber = null,
    Object? userId = null,
    Object? memberId = freezed,
    Object? category = freezed,
    Object? amount = null,
    Object? transferDate = null,
    Object? senderBank = null,
    Object? depositorPhone = freezed,
    Object? proofFileUrl = freezed,
    Object? status = null,
    Object? notes = freezed,
    Object? rejectionReason = freezed,
    Object? reviewedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$DonationConfirmationModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      donationNumber: null == donationNumber
          ? _value.donationNumber
          : donationNumber // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      memberId: freezed == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as int?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ChartOfAccountModel?,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as num,
      transferDate: null == transferDate
          ? _value.transferDate
          : transferDate // ignore: cast_nullable_to_non_nullable
              as String,
      senderBank: null == senderBank
          ? _value.senderBank
          : senderBank // ignore: cast_nullable_to_non_nullable
              as String,
      depositorPhone: freezed == depositorPhone
          ? _value.depositorPhone
          : depositorPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      proofFileUrl: freezed == proofFileUrl
          ? _value.proofFileUrl
          : proofFileUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      rejectionReason: freezed == rejectionReason
          ? _value.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
      reviewedAt: freezed == reviewedAt
          ? _value.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
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
class _$DonationConfirmationModelImpl extends _DonationConfirmationModel {
  const _$DonationConfirmationModelImpl(
      {required this.id,
      @JsonKey(name: 'donation_number') required this.donationNumber,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'member_id') this.memberId,
      this.category,
      required this.amount,
      @JsonKey(name: 'transfer_date') required this.transferDate,
      @JsonKey(name: 'sender_bank') required this.senderBank,
      @JsonKey(name: 'depositor_phone') this.depositorPhone,
      @JsonKey(name: 'proof_file_url') this.proofFileUrl,
      required this.status,
      this.notes,
      @JsonKey(name: 'rejection_reason') this.rejectionReason,
      @JsonKey(name: 'reviewed_at') this.reviewedAt,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt})
      : super._();

  factory _$DonationConfirmationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DonationConfirmationModelImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'donation_number')
  final String donationNumber;
  @override
  @JsonKey(name: 'user_id')
  final int userId;
  @override
  @JsonKey(name: 'member_id')
  final int? memberId;
  @override
  final ChartOfAccountModel? category;
  @override
  final num amount;
  @override
  @JsonKey(name: 'transfer_date')
  final String transferDate;
  @override
  @JsonKey(name: 'sender_bank')
  final String senderBank;
  @override
  @JsonKey(name: 'depositor_phone')
  final String? depositorPhone;
  @override
  @JsonKey(name: 'proof_file_url')
  final String? proofFileUrl;
  @override
  final String status;
  @override
  final String? notes;
  @override
  @JsonKey(name: 'rejection_reason')
  final String? rejectionReason;
  @override
  @JsonKey(name: 'reviewed_at')
  final String? reviewedAt;
  @override
  @JsonKey(name: 'created_at')
  final String createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  @override
  String toString() {
    return 'DonationConfirmationModel(id: $id, donationNumber: $donationNumber, userId: $userId, memberId: $memberId, category: $category, amount: $amount, transferDate: $transferDate, senderBank: $senderBank, depositorPhone: $depositorPhone, proofFileUrl: $proofFileUrl, status: $status, notes: $notes, rejectionReason: $rejectionReason, reviewedAt: $reviewedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DonationConfirmationModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.donationNumber, donationNumber) ||
                other.donationNumber == donationNumber) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.memberId, memberId) ||
                other.memberId == memberId) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.transferDate, transferDate) ||
                other.transferDate == transferDate) &&
            (identical(other.senderBank, senderBank) ||
                other.senderBank == senderBank) &&
            (identical(other.depositorPhone, depositorPhone) ||
                other.depositorPhone == depositorPhone) &&
            (identical(other.proofFileUrl, proofFileUrl) ||
                other.proofFileUrl == proofFileUrl) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason) &&
            (identical(other.reviewedAt, reviewedAt) ||
                other.reviewedAt == reviewedAt) &&
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
      donationNumber,
      userId,
      memberId,
      category,
      amount,
      transferDate,
      senderBank,
      depositorPhone,
      proofFileUrl,
      status,
      notes,
      rejectionReason,
      reviewedAt,
      createdAt,
      updatedAt);

  /// Create a copy of DonationConfirmationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DonationConfirmationModelImplCopyWith<_$DonationConfirmationModelImpl>
      get copyWith => __$$DonationConfirmationModelImplCopyWithImpl<
          _$DonationConfirmationModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DonationConfirmationModelImplToJson(
      this,
    );
  }
}

abstract class _DonationConfirmationModel extends DonationConfirmationModel {
  const factory _DonationConfirmationModel(
      {required final int id,
      @JsonKey(name: 'donation_number') required final String donationNumber,
      @JsonKey(name: 'user_id') required final int userId,
      @JsonKey(name: 'member_id') final int? memberId,
      final ChartOfAccountModel? category,
      required final num amount,
      @JsonKey(name: 'transfer_date') required final String transferDate,
      @JsonKey(name: 'sender_bank') required final String senderBank,
      @JsonKey(name: 'depositor_phone') final String? depositorPhone,
      @JsonKey(name: 'proof_file_url') final String? proofFileUrl,
      required final String status,
      final String? notes,
      @JsonKey(name: 'rejection_reason') final String? rejectionReason,
      @JsonKey(name: 'reviewed_at') final String? reviewedAt,
      @JsonKey(name: 'created_at') required final String createdAt,
      @JsonKey(name: 'updated_at')
      required final String updatedAt}) = _$DonationConfirmationModelImpl;
  const _DonationConfirmationModel._() : super._();

  factory _DonationConfirmationModel.fromJson(Map<String, dynamic> json) =
      _$DonationConfirmationModelImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'donation_number')
  String get donationNumber;
  @override
  @JsonKey(name: 'user_id')
  int get userId;
  @override
  @JsonKey(name: 'member_id')
  int? get memberId;
  @override
  ChartOfAccountModel? get category;
  @override
  num get amount;
  @override
  @JsonKey(name: 'transfer_date')
  String get transferDate;
  @override
  @JsonKey(name: 'sender_bank')
  String get senderBank;
  @override
  @JsonKey(name: 'depositor_phone')
  String? get depositorPhone;
  @override
  @JsonKey(name: 'proof_file_url')
  String? get proofFileUrl;
  @override
  String get status;
  @override
  String? get notes;
  @override
  @JsonKey(name: 'rejection_reason')
  String? get rejectionReason;
  @override
  @JsonKey(name: 'reviewed_at')
  String? get reviewedAt;
  @override
  @JsonKey(name: 'created_at')
  String get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String get updatedAt;

  /// Create a copy of DonationConfirmationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DonationConfirmationModelImplCopyWith<_$DonationConfirmationModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
