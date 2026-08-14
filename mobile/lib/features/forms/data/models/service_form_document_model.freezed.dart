// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service_form_document_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ServiceFormDocumentModel _$ServiceFormDocumentModelFromJson(
    Map<String, dynamic> json) {
  return _ServiceFormDocumentModel.fromJson(json);
}

/// @nodoc
mixin _$ServiceFormDocumentModel {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'service_form_application_id')
  int get serviceFormApplicationId => throw _privateConstructorUsedError;
  @JsonKey(name: 'document_name')
  String get documentName => throw _privateConstructorUsedError;
  @JsonKey(name: 'file_name')
  String get fileName => throw _privateConstructorUsedError;
  @JsonKey(name: 'mime_type')
  String get mimeType => throw _privateConstructorUsedError;
  @JsonKey(name: 'file_size')
  int get fileSize => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ServiceFormDocumentModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ServiceFormDocumentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ServiceFormDocumentModelCopyWith<ServiceFormDocumentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServiceFormDocumentModelCopyWith<$Res> {
  factory $ServiceFormDocumentModelCopyWith(ServiceFormDocumentModel value,
          $Res Function(ServiceFormDocumentModel) then) =
      _$ServiceFormDocumentModelCopyWithImpl<$Res, ServiceFormDocumentModel>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'service_form_application_id')
      int serviceFormApplicationId,
      @JsonKey(name: 'document_name') String documentName,
      @JsonKey(name: 'file_name') String fileName,
      @JsonKey(name: 'mime_type') String mimeType,
      @JsonKey(name: 'file_size') int fileSize,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt});
}

/// @nodoc
class _$ServiceFormDocumentModelCopyWithImpl<$Res,
        $Val extends ServiceFormDocumentModel>
    implements $ServiceFormDocumentModelCopyWith<$Res> {
  _$ServiceFormDocumentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ServiceFormDocumentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? serviceFormApplicationId = null,
    Object? documentName = null,
    Object? fileName = null,
    Object? mimeType = null,
    Object? fileSize = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      serviceFormApplicationId: null == serviceFormApplicationId
          ? _value.serviceFormApplicationId
          : serviceFormApplicationId // ignore: cast_nullable_to_non_nullable
              as int,
      documentName: null == documentName
          ? _value.documentName
          : documentName // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      mimeType: null == mimeType
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: null == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int,
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
abstract class _$$ServiceFormDocumentModelImplCopyWith<$Res>
    implements $ServiceFormDocumentModelCopyWith<$Res> {
  factory _$$ServiceFormDocumentModelImplCopyWith(
          _$ServiceFormDocumentModelImpl value,
          $Res Function(_$ServiceFormDocumentModelImpl) then) =
      __$$ServiceFormDocumentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'service_form_application_id')
      int serviceFormApplicationId,
      @JsonKey(name: 'document_name') String documentName,
      @JsonKey(name: 'file_name') String fileName,
      @JsonKey(name: 'mime_type') String mimeType,
      @JsonKey(name: 'file_size') int fileSize,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt});
}

/// @nodoc
class __$$ServiceFormDocumentModelImplCopyWithImpl<$Res>
    extends _$ServiceFormDocumentModelCopyWithImpl<$Res,
        _$ServiceFormDocumentModelImpl>
    implements _$$ServiceFormDocumentModelImplCopyWith<$Res> {
  __$$ServiceFormDocumentModelImplCopyWithImpl(
      _$ServiceFormDocumentModelImpl _value,
      $Res Function(_$ServiceFormDocumentModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ServiceFormDocumentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? serviceFormApplicationId = null,
    Object? documentName = null,
    Object? fileName = null,
    Object? mimeType = null,
    Object? fileSize = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$ServiceFormDocumentModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      serviceFormApplicationId: null == serviceFormApplicationId
          ? _value.serviceFormApplicationId
          : serviceFormApplicationId // ignore: cast_nullable_to_non_nullable
              as int,
      documentName: null == documentName
          ? _value.documentName
          : documentName // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      mimeType: null == mimeType
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: null == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int,
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
class _$ServiceFormDocumentModelImpl extends _ServiceFormDocumentModel {
  const _$ServiceFormDocumentModelImpl(
      {required this.id,
      @JsonKey(name: 'service_form_application_id')
      required this.serviceFormApplicationId,
      @JsonKey(name: 'document_name') required this.documentName,
      @JsonKey(name: 'file_name') required this.fileName,
      @JsonKey(name: 'mime_type') required this.mimeType,
      @JsonKey(name: 'file_size') required this.fileSize,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : super._();

  factory _$ServiceFormDocumentModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServiceFormDocumentModelImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'service_form_application_id')
  final int serviceFormApplicationId;
  @override
  @JsonKey(name: 'document_name')
  final String documentName;
  @override
  @JsonKey(name: 'file_name')
  final String fileName;
  @override
  @JsonKey(name: 'mime_type')
  final String mimeType;
  @override
  @JsonKey(name: 'file_size')
  final int fileSize;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @override
  String toString() {
    return 'ServiceFormDocumentModel(id: $id, serviceFormApplicationId: $serviceFormApplicationId, documentName: $documentName, fileName: $fileName, mimeType: $mimeType, fileSize: $fileSize, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServiceFormDocumentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(
                    other.serviceFormApplicationId, serviceFormApplicationId) ||
                other.serviceFormApplicationId == serviceFormApplicationId) &&
            (identical(other.documentName, documentName) ||
                other.documentName == documentName) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, serviceFormApplicationId,
      documentName, fileName, mimeType, fileSize, createdAt, updatedAt);

  /// Create a copy of ServiceFormDocumentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServiceFormDocumentModelImplCopyWith<_$ServiceFormDocumentModelImpl>
      get copyWith => __$$ServiceFormDocumentModelImplCopyWithImpl<
          _$ServiceFormDocumentModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ServiceFormDocumentModelImplToJson(
      this,
    );
  }
}

abstract class _ServiceFormDocumentModel extends ServiceFormDocumentModel {
  const factory _ServiceFormDocumentModel(
          {required final int id,
          @JsonKey(name: 'service_form_application_id')
          required final int serviceFormApplicationId,
          @JsonKey(name: 'document_name') required final String documentName,
          @JsonKey(name: 'file_name') required final String fileName,
          @JsonKey(name: 'mime_type') required final String mimeType,
          @JsonKey(name: 'file_size') required final int fileSize,
          @JsonKey(name: 'created_at') final String? createdAt,
          @JsonKey(name: 'updated_at') final String? updatedAt}) =
      _$ServiceFormDocumentModelImpl;
  const _ServiceFormDocumentModel._() : super._();

  factory _ServiceFormDocumentModel.fromJson(Map<String, dynamic> json) =
      _$ServiceFormDocumentModelImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'service_form_application_id')
  int get serviceFormApplicationId;
  @override
  @JsonKey(name: 'document_name')
  String get documentName;
  @override
  @JsonKey(name: 'file_name')
  String get fileName;
  @override
  @JsonKey(name: 'mime_type')
  String get mimeType;
  @override
  @JsonKey(name: 'file_size')
  int get fileSize;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String? get updatedAt;

  /// Create a copy of ServiceFormDocumentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServiceFormDocumentModelImplCopyWith<_$ServiceFormDocumentModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
