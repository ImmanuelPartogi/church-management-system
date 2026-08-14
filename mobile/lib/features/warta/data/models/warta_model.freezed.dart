// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'warta_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WartaModel _$WartaModelFromJson(Map<String, dynamic> json) {
  return _WartaModel.fromJson(json);
}

/// @nodoc
mixin _$WartaModel {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'file_name')
  String get fileName => throw _privateConstructorUsedError;
  @JsonKey(name: 'file_size')
  int get fileSize => throw _privateConstructorUsedError;
  @JsonKey(name: 'mime_type')
  String get mimeType => throw _privateConstructorUsedError;
  @JsonKey(name: 'published_at')
  String get publishedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_published')
  bool get isPublished => throw _privateConstructorUsedError;
  @JsonKey(name: 'download_count')
  int get downloadCount => throw _privateConstructorUsedError;

  /// Serializes this WartaModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WartaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WartaModelCopyWith<WartaModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WartaModelCopyWith<$Res> {
  factory $WartaModelCopyWith(
          WartaModel value, $Res Function(WartaModel) then) =
      _$WartaModelCopyWithImpl<$Res, WartaModel>;
  @useResult
  $Res call(
      {int id,
      String title,
      String? description,
      @JsonKey(name: 'file_name') String fileName,
      @JsonKey(name: 'file_size') int fileSize,
      @JsonKey(name: 'mime_type') String mimeType,
      @JsonKey(name: 'published_at') String publishedAt,
      @JsonKey(name: 'is_published') bool isPublished,
      @JsonKey(name: 'download_count') int downloadCount});
}

/// @nodoc
class _$WartaModelCopyWithImpl<$Res, $Val extends WartaModel>
    implements $WartaModelCopyWith<$Res> {
  _$WartaModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WartaModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? fileName = null,
    Object? fileSize = null,
    Object? mimeType = null,
    Object? publishedAt = null,
    Object? isPublished = null,
    Object? downloadCount = null,
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
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: null == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int,
      mimeType: null == mimeType
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String,
      publishedAt: null == publishedAt
          ? _value.publishedAt
          : publishedAt // ignore: cast_nullable_to_non_nullable
              as String,
      isPublished: null == isPublished
          ? _value.isPublished
          : isPublished // ignore: cast_nullable_to_non_nullable
              as bool,
      downloadCount: null == downloadCount
          ? _value.downloadCount
          : downloadCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WartaModelImplCopyWith<$Res>
    implements $WartaModelCopyWith<$Res> {
  factory _$$WartaModelImplCopyWith(
          _$WartaModelImpl value, $Res Function(_$WartaModelImpl) then) =
      __$$WartaModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String title,
      String? description,
      @JsonKey(name: 'file_name') String fileName,
      @JsonKey(name: 'file_size') int fileSize,
      @JsonKey(name: 'mime_type') String mimeType,
      @JsonKey(name: 'published_at') String publishedAt,
      @JsonKey(name: 'is_published') bool isPublished,
      @JsonKey(name: 'download_count') int downloadCount});
}

/// @nodoc
class __$$WartaModelImplCopyWithImpl<$Res>
    extends _$WartaModelCopyWithImpl<$Res, _$WartaModelImpl>
    implements _$$WartaModelImplCopyWith<$Res> {
  __$$WartaModelImplCopyWithImpl(
      _$WartaModelImpl _value, $Res Function(_$WartaModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of WartaModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? fileName = null,
    Object? fileSize = null,
    Object? mimeType = null,
    Object? publishedAt = null,
    Object? isPublished = null,
    Object? downloadCount = null,
  }) {
    return _then(_$WartaModelImpl(
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
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: null == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int,
      mimeType: null == mimeType
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String,
      publishedAt: null == publishedAt
          ? _value.publishedAt
          : publishedAt // ignore: cast_nullable_to_non_nullable
              as String,
      isPublished: null == isPublished
          ? _value.isPublished
          : isPublished // ignore: cast_nullable_to_non_nullable
              as bool,
      downloadCount: null == downloadCount
          ? _value.downloadCount
          : downloadCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WartaModelImpl extends _WartaModel {
  const _$WartaModelImpl(
      {required this.id,
      required this.title,
      this.description,
      @JsonKey(name: 'file_name') required this.fileName,
      @JsonKey(name: 'file_size') required this.fileSize,
      @JsonKey(name: 'mime_type') required this.mimeType,
      @JsonKey(name: 'published_at') required this.publishedAt,
      @JsonKey(name: 'is_published') required this.isPublished,
      @JsonKey(name: 'download_count') required this.downloadCount})
      : super._();

  factory _$WartaModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$WartaModelImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final String? description;
  @override
  @JsonKey(name: 'file_name')
  final String fileName;
  @override
  @JsonKey(name: 'file_size')
  final int fileSize;
  @override
  @JsonKey(name: 'mime_type')
  final String mimeType;
  @override
  @JsonKey(name: 'published_at')
  final String publishedAt;
  @override
  @JsonKey(name: 'is_published')
  final bool isPublished;
  @override
  @JsonKey(name: 'download_count')
  final int downloadCount;

  @override
  String toString() {
    return 'WartaModel(id: $id, title: $title, description: $description, fileName: $fileName, fileSize: $fileSize, mimeType: $mimeType, publishedAt: $publishedAt, isPublished: $isPublished, downloadCount: $downloadCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WartaModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType) &&
            (identical(other.publishedAt, publishedAt) ||
                other.publishedAt == publishedAt) &&
            (identical(other.isPublished, isPublished) ||
                other.isPublished == isPublished) &&
            (identical(other.downloadCount, downloadCount) ||
                other.downloadCount == downloadCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, description, fileName,
      fileSize, mimeType, publishedAt, isPublished, downloadCount);

  /// Create a copy of WartaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WartaModelImplCopyWith<_$WartaModelImpl> get copyWith =>
      __$$WartaModelImplCopyWithImpl<_$WartaModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WartaModelImplToJson(
      this,
    );
  }
}

abstract class _WartaModel extends WartaModel {
  const factory _WartaModel(
          {required final int id,
          required final String title,
          final String? description,
          @JsonKey(name: 'file_name') required final String fileName,
          @JsonKey(name: 'file_size') required final int fileSize,
          @JsonKey(name: 'mime_type') required final String mimeType,
          @JsonKey(name: 'published_at') required final String publishedAt,
          @JsonKey(name: 'is_published') required final bool isPublished,
          @JsonKey(name: 'download_count') required final int downloadCount}) =
      _$WartaModelImpl;
  const _WartaModel._() : super._();

  factory _WartaModel.fromJson(Map<String, dynamic> json) =
      _$WartaModelImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  String? get description;
  @override
  @JsonKey(name: 'file_name')
  String get fileName;
  @override
  @JsonKey(name: 'file_size')
  int get fileSize;
  @override
  @JsonKey(name: 'mime_type')
  String get mimeType;
  @override
  @JsonKey(name: 'published_at')
  String get publishedAt;
  @override
  @JsonKey(name: 'is_published')
  bool get isPublished;
  @override
  @JsonKey(name: 'download_count')
  int get downloadCount;

  /// Create a copy of WartaModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WartaModelImplCopyWith<_$WartaModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
