// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service_form_application_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ServiceFormApplicationModel _$ServiceFormApplicationModelFromJson(
    Map<String, dynamic> json) {
  return _ServiceFormApplicationModel.fromJson(json);
}

/// @nodoc
mixin _$ServiceFormApplicationModel {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'application_number')
  String get applicationNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  int get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'member_id')
  int? get memberId => throw _privateConstructorUsedError;
  @JsonKey(name: 'service_form_type')
  ServiceFormTypeModel? get serviceFormType =>
      throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'applicant_notes')
  String? get applicantNotes => throw _privateConstructorUsedError;
  @JsonKey(name: 'rejection_reason')
  String? get rejectionReason => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_status')
  String get paymentStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_notes')
  String? get paymentNotes => throw _privateConstructorUsedError;
  @JsonKey(name: 'reviewed_at')
  String? get reviewedAt => throw _privateConstructorUsedError;
  List<ServiceFormDocumentModel> get documents =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ServiceFormApplicationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ServiceFormApplicationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ServiceFormApplicationModelCopyWith<ServiceFormApplicationModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServiceFormApplicationModelCopyWith<$Res> {
  factory $ServiceFormApplicationModelCopyWith(
          ServiceFormApplicationModel value,
          $Res Function(ServiceFormApplicationModel) then) =
      _$ServiceFormApplicationModelCopyWithImpl<$Res,
          ServiceFormApplicationModel>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'application_number') String applicationNumber,
      @JsonKey(name: 'user_id') int userId,
      @JsonKey(name: 'member_id') int? memberId,
      @JsonKey(name: 'service_form_type') ServiceFormTypeModel? serviceFormType,
      String status,
      @JsonKey(name: 'applicant_notes') String? applicantNotes,
      @JsonKey(name: 'rejection_reason') String? rejectionReason,
      @JsonKey(name: 'payment_status') String paymentStatus,
      @JsonKey(name: 'payment_notes') String? paymentNotes,
      @JsonKey(name: 'reviewed_at') String? reviewedAt,
      List<ServiceFormDocumentModel> documents,
      @JsonKey(name: 'created_at') String createdAt,
      @JsonKey(name: 'updated_at') String updatedAt});

  $ServiceFormTypeModelCopyWith<$Res>? get serviceFormType;
}

/// @nodoc
class _$ServiceFormApplicationModelCopyWithImpl<$Res,
        $Val extends ServiceFormApplicationModel>
    implements $ServiceFormApplicationModelCopyWith<$Res> {
  _$ServiceFormApplicationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ServiceFormApplicationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? applicationNumber = null,
    Object? userId = null,
    Object? memberId = freezed,
    Object? serviceFormType = freezed,
    Object? status = null,
    Object? applicantNotes = freezed,
    Object? rejectionReason = freezed,
    Object? paymentStatus = null,
    Object? paymentNotes = freezed,
    Object? reviewedAt = freezed,
    Object? documents = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      applicationNumber: null == applicationNumber
          ? _value.applicationNumber
          : applicationNumber // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      memberId: freezed == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as int?,
      serviceFormType: freezed == serviceFormType
          ? _value.serviceFormType
          : serviceFormType // ignore: cast_nullable_to_non_nullable
              as ServiceFormTypeModel?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      applicantNotes: freezed == applicantNotes
          ? _value.applicantNotes
          : applicantNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      rejectionReason: freezed == rejectionReason
          ? _value.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String,
      paymentNotes: freezed == paymentNotes
          ? _value.paymentNotes
          : paymentNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      reviewedAt: freezed == reviewedAt
          ? _value.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      documents: null == documents
          ? _value.documents
          : documents // ignore: cast_nullable_to_non_nullable
              as List<ServiceFormDocumentModel>,
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

  /// Create a copy of ServiceFormApplicationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ServiceFormTypeModelCopyWith<$Res>? get serviceFormType {
    if (_value.serviceFormType == null) {
      return null;
    }

    return $ServiceFormTypeModelCopyWith<$Res>(_value.serviceFormType!,
        (value) {
      return _then(_value.copyWith(serviceFormType: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ServiceFormApplicationModelImplCopyWith<$Res>
    implements $ServiceFormApplicationModelCopyWith<$Res> {
  factory _$$ServiceFormApplicationModelImplCopyWith(
          _$ServiceFormApplicationModelImpl value,
          $Res Function(_$ServiceFormApplicationModelImpl) then) =
      __$$ServiceFormApplicationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'application_number') String applicationNumber,
      @JsonKey(name: 'user_id') int userId,
      @JsonKey(name: 'member_id') int? memberId,
      @JsonKey(name: 'service_form_type') ServiceFormTypeModel? serviceFormType,
      String status,
      @JsonKey(name: 'applicant_notes') String? applicantNotes,
      @JsonKey(name: 'rejection_reason') String? rejectionReason,
      @JsonKey(name: 'payment_status') String paymentStatus,
      @JsonKey(name: 'payment_notes') String? paymentNotes,
      @JsonKey(name: 'reviewed_at') String? reviewedAt,
      List<ServiceFormDocumentModel> documents,
      @JsonKey(name: 'created_at') String createdAt,
      @JsonKey(name: 'updated_at') String updatedAt});

  @override
  $ServiceFormTypeModelCopyWith<$Res>? get serviceFormType;
}

/// @nodoc
class __$$ServiceFormApplicationModelImplCopyWithImpl<$Res>
    extends _$ServiceFormApplicationModelCopyWithImpl<$Res,
        _$ServiceFormApplicationModelImpl>
    implements _$$ServiceFormApplicationModelImplCopyWith<$Res> {
  __$$ServiceFormApplicationModelImplCopyWithImpl(
      _$ServiceFormApplicationModelImpl _value,
      $Res Function(_$ServiceFormApplicationModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ServiceFormApplicationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? applicationNumber = null,
    Object? userId = null,
    Object? memberId = freezed,
    Object? serviceFormType = freezed,
    Object? status = null,
    Object? applicantNotes = freezed,
    Object? rejectionReason = freezed,
    Object? paymentStatus = null,
    Object? paymentNotes = freezed,
    Object? reviewedAt = freezed,
    Object? documents = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$ServiceFormApplicationModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      applicationNumber: null == applicationNumber
          ? _value.applicationNumber
          : applicationNumber // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      memberId: freezed == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as int?,
      serviceFormType: freezed == serviceFormType
          ? _value.serviceFormType
          : serviceFormType // ignore: cast_nullable_to_non_nullable
              as ServiceFormTypeModel?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      applicantNotes: freezed == applicantNotes
          ? _value.applicantNotes
          : applicantNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      rejectionReason: freezed == rejectionReason
          ? _value.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String,
      paymentNotes: freezed == paymentNotes
          ? _value.paymentNotes
          : paymentNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      reviewedAt: freezed == reviewedAt
          ? _value.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      documents: null == documents
          ? _value._documents
          : documents // ignore: cast_nullable_to_non_nullable
              as List<ServiceFormDocumentModel>,
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
class _$ServiceFormApplicationModelImpl extends _ServiceFormApplicationModel {
  const _$ServiceFormApplicationModelImpl(
      {required this.id,
      @JsonKey(name: 'application_number') required this.applicationNumber,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'member_id') this.memberId,
      @JsonKey(name: 'service_form_type') this.serviceFormType,
      required this.status,
      @JsonKey(name: 'applicant_notes') this.applicantNotes,
      @JsonKey(name: 'rejection_reason') this.rejectionReason,
      @JsonKey(name: 'payment_status') required this.paymentStatus,
      @JsonKey(name: 'payment_notes') this.paymentNotes,
      @JsonKey(name: 'reviewed_at') this.reviewedAt,
      final List<ServiceFormDocumentModel> documents = const [],
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt})
      : _documents = documents,
        super._();

  factory _$ServiceFormApplicationModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$ServiceFormApplicationModelImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'application_number')
  final String applicationNumber;
  @override
  @JsonKey(name: 'user_id')
  final int userId;
  @override
  @JsonKey(name: 'member_id')
  final int? memberId;
  @override
  @JsonKey(name: 'service_form_type')
  final ServiceFormTypeModel? serviceFormType;
  @override
  final String status;
  @override
  @JsonKey(name: 'applicant_notes')
  final String? applicantNotes;
  @override
  @JsonKey(name: 'rejection_reason')
  final String? rejectionReason;
  @override
  @JsonKey(name: 'payment_status')
  final String paymentStatus;
  @override
  @JsonKey(name: 'payment_notes')
  final String? paymentNotes;
  @override
  @JsonKey(name: 'reviewed_at')
  final String? reviewedAt;
  final List<ServiceFormDocumentModel> _documents;
  @override
  @JsonKey()
  List<ServiceFormDocumentModel> get documents {
    if (_documents is EqualUnmodifiableListView) return _documents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_documents);
  }

  @override
  @JsonKey(name: 'created_at')
  final String createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  @override
  String toString() {
    return 'ServiceFormApplicationModel(id: $id, applicationNumber: $applicationNumber, userId: $userId, memberId: $memberId, serviceFormType: $serviceFormType, status: $status, applicantNotes: $applicantNotes, rejectionReason: $rejectionReason, paymentStatus: $paymentStatus, paymentNotes: $paymentNotes, reviewedAt: $reviewedAt, documents: $documents, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServiceFormApplicationModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.applicationNumber, applicationNumber) ||
                other.applicationNumber == applicationNumber) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.memberId, memberId) ||
                other.memberId == memberId) &&
            (identical(other.serviceFormType, serviceFormType) ||
                other.serviceFormType == serviceFormType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.applicantNotes, applicantNotes) ||
                other.applicantNotes == applicantNotes) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.paymentNotes, paymentNotes) ||
                other.paymentNotes == paymentNotes) &&
            (identical(other.reviewedAt, reviewedAt) ||
                other.reviewedAt == reviewedAt) &&
            const DeepCollectionEquality()
                .equals(other._documents, _documents) &&
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
      applicationNumber,
      userId,
      memberId,
      serviceFormType,
      status,
      applicantNotes,
      rejectionReason,
      paymentStatus,
      paymentNotes,
      reviewedAt,
      const DeepCollectionEquality().hash(_documents),
      createdAt,
      updatedAt);

  /// Create a copy of ServiceFormApplicationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServiceFormApplicationModelImplCopyWith<_$ServiceFormApplicationModelImpl>
      get copyWith => __$$ServiceFormApplicationModelImplCopyWithImpl<
          _$ServiceFormApplicationModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ServiceFormApplicationModelImplToJson(
      this,
    );
  }
}

abstract class _ServiceFormApplicationModel
    extends ServiceFormApplicationModel {
  const factory _ServiceFormApplicationModel(
          {required final int id,
          @JsonKey(name: 'application_number')
          required final String applicationNumber,
          @JsonKey(name: 'user_id') required final int userId,
          @JsonKey(name: 'member_id') final int? memberId,
          @JsonKey(name: 'service_form_type')
          final ServiceFormTypeModel? serviceFormType,
          required final String status,
          @JsonKey(name: 'applicant_notes') final String? applicantNotes,
          @JsonKey(name: 'rejection_reason') final String? rejectionReason,
          @JsonKey(name: 'payment_status') required final String paymentStatus,
          @JsonKey(name: 'payment_notes') final String? paymentNotes,
          @JsonKey(name: 'reviewed_at') final String? reviewedAt,
          final List<ServiceFormDocumentModel> documents,
          @JsonKey(name: 'created_at') required final String createdAt,
          @JsonKey(name: 'updated_at') required final String updatedAt}) =
      _$ServiceFormApplicationModelImpl;
  const _ServiceFormApplicationModel._() : super._();

  factory _ServiceFormApplicationModel.fromJson(Map<String, dynamic> json) =
      _$ServiceFormApplicationModelImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'application_number')
  String get applicationNumber;
  @override
  @JsonKey(name: 'user_id')
  int get userId;
  @override
  @JsonKey(name: 'member_id')
  int? get memberId;
  @override
  @JsonKey(name: 'service_form_type')
  ServiceFormTypeModel? get serviceFormType;
  @override
  String get status;
  @override
  @JsonKey(name: 'applicant_notes')
  String? get applicantNotes;
  @override
  @JsonKey(name: 'rejection_reason')
  String? get rejectionReason;
  @override
  @JsonKey(name: 'payment_status')
  String get paymentStatus;
  @override
  @JsonKey(name: 'payment_notes')
  String? get paymentNotes;
  @override
  @JsonKey(name: 'reviewed_at')
  String? get reviewedAt;
  @override
  List<ServiceFormDocumentModel> get documents;
  @override
  @JsonKey(name: 'created_at')
  String get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String get updatedAt;

  /// Create a copy of ServiceFormApplicationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServiceFormApplicationModelImplCopyWith<_$ServiceFormApplicationModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
