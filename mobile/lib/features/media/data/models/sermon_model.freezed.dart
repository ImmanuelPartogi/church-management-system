// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sermon_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SermonModel _$SermonModelFromJson(Map<String, dynamic> json) {
  return _SermonModel.fromJson(json);
}

/// @nodoc
mixin _$SermonModel {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'preacher_name')
  String get preacherName => throw _privateConstructorUsedError;
  @JsonKey(name: 'file_name')
  String? get fileName => throw _privateConstructorUsedError;
  @JsonKey(name: 'file_size')
  int? get fileSize => throw _privateConstructorUsedError;
  @JsonKey(name: 'mime_type')
  String? get mimeType => throw _privateConstructorUsedError;
  @JsonKey(name: 'download_count')
  int get downloadCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'published_at')
  String? get publishedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_published')
  bool get isPublished => throw _privateConstructorUsedError;

  /// Serializes this SermonModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SermonModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SermonModelCopyWith<SermonModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SermonModelCopyWith<$Res> {
  factory $SermonModelCopyWith(
          SermonModel value, $Res Function(SermonModel) then) =
      _$SermonModelCopyWithImpl<$Res, SermonModel>;
  @useResult
  $Res call(
      {int id,
      String title,
      String? description,
      @JsonKey(name: 'preacher_name') String preacherName,
      @JsonKey(name: 'file_name') String? fileName,
      @JsonKey(name: 'file_size') int? fileSize,
      @JsonKey(name: 'mime_type') String? mimeType,
      @JsonKey(name: 'download_count') int downloadCount,
      @JsonKey(name: 'published_at') String? publishedAt,
      @JsonKey(name: 'is_published') bool isPublished});
}

/// @nodoc
class _$SermonModelCopyWithImpl<$Res, $Val extends SermonModel>
    implements $SermonModelCopyWith<$Res> {
  _$SermonModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SermonModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? preacherName = null,
    Object? fileName = freezed,
    Object? fileSize = freezed,
    Object? mimeType = freezed,
    Object? downloadCount = null,
    Object? publishedAt = freezed,
    Object? isPublished = null,
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
      preacherName: null == preacherName
          ? _value.preacherName
          : preacherName // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: freezed == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String?,
      fileSize: freezed == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int?,
      mimeType: freezed == mimeType
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String?,
      downloadCount: null == downloadCount
          ? _value.downloadCount
          : downloadCount // ignore: cast_nullable_to_non_nullable
              as int,
      publishedAt: freezed == publishedAt
          ? _value.publishedAt
          : publishedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      isPublished: null == isPublished
          ? _value.isPublished
          : isPublished // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SermonModelImplCopyWith<$Res>
    implements $SermonModelCopyWith<$Res> {
  factory _$$SermonModelImplCopyWith(
          _$SermonModelImpl value, $Res Function(_$SermonModelImpl) then) =
      __$$SermonModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String title,
      String? description,
      @JsonKey(name: 'preacher_name') String preacherName,
      @JsonKey(name: 'file_name') String? fileName,
      @JsonKey(name: 'file_size') int? fileSize,
      @JsonKey(name: 'mime_type') String? mimeType,
      @JsonKey(name: 'download_count') int downloadCount,
      @JsonKey(name: 'published_at') String? publishedAt,
      @JsonKey(name: 'is_published') bool isPublished});
}

/// @nodoc
class __$$SermonModelImplCopyWithImpl<$Res>
    extends _$SermonModelCopyWithImpl<$Res, _$SermonModelImpl>
    implements _$$SermonModelImplCopyWith<$Res> {
  __$$SermonModelImplCopyWithImpl(
      _$SermonModelImpl _value, $Res Function(_$SermonModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SermonModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? preacherName = null,
    Object? fileName = freezed,
    Object? fileSize = freezed,
    Object? mimeType = freezed,
    Object? downloadCount = null,
    Object? publishedAt = freezed,
    Object? isPublished = null,
  }) {
    return _then(_$SermonModelImpl(
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
      preacherName: null == preacherName
          ? _value.preacherName
          : preacherName // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: freezed == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String?,
      fileSize: freezed == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int?,
      mimeType: freezed == mimeType
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String?,
      downloadCount: null == downloadCount
          ? _value.downloadCount
          : downloadCount // ignore: cast_nullable_to_non_nullable
              as int,
      publishedAt: freezed == publishedAt
          ? _value.publishedAt
          : publishedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      isPublished: null == isPublished
          ? _value.isPublished
          : isPublished // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SermonModelImpl extends _SermonModel {
  const _$SermonModelImpl(
      {required this.id,
      required this.title,
      this.description,
      @JsonKey(name: 'preacher_name') required this.preacherName,
      @JsonKey(name: 'file_name') this.fileName,
      @JsonKey(name: 'file_size') this.fileSize,
      @JsonKey(name: 'mime_type') this.mimeType,
      @JsonKey(name: 'download_count') this.downloadCount = 0,
      @JsonKey(name: 'published_at') this.publishedAt,
      @JsonKey(name: 'is_published') this.isPublished = true})
      : super._();

  factory _$SermonModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SermonModelImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final String? description;
  @override
  @JsonKey(name: 'preacher_name')
  final String preacherName;
  @override
  @JsonKey(name: 'file_name')
  final String? fileName;
  @override
  @JsonKey(name: 'file_size')
  final int? fileSize;
  @override
  @JsonKey(name: 'mime_type')
  final String? mimeType;
  @override
  @JsonKey(name: 'download_count')
  final int downloadCount;
  @override
  @JsonKey(name: 'published_at')
  final String? publishedAt;
  @override
  @JsonKey(name: 'is_published')
  final bool isPublished;

  @override
  String toString() {
    return 'SermonModel(id: $id, title: $title, description: $description, preacherName: $preacherName, fileName: $fileName, fileSize: $fileSize, mimeType: $mimeType, downloadCount: $downloadCount, publishedAt: $publishedAt, isPublished: $isPublished)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SermonModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.preacherName, preacherName) ||
                other.preacherName == preacherName) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType) &&
            (identical(other.downloadCount, downloadCount) ||
                other.downloadCount == downloadCount) &&
            (identical(other.publishedAt, publishedAt) ||
                other.publishedAt == publishedAt) &&
            (identical(other.isPublished, isPublished) ||
                other.isPublished == isPublished));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      preacherName,
      fileName,
      fileSize,
      mimeType,
      downloadCount,
      publishedAt,
      isPublished);

  /// Create a copy of SermonModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SermonModelImplCopyWith<_$SermonModelImpl> get copyWith =>
      __$$SermonModelImplCopyWithImpl<_$SermonModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SermonModelImplToJson(
      this,
    );
  }
}

abstract class _SermonModel extends SermonModel {
  const factory _SermonModel(
          {required final int id,
          required final String title,
          final String? description,
          @JsonKey(name: 'preacher_name') required final String preacherName,
          @JsonKey(name: 'file_name') final String? fileName,
          @JsonKey(name: 'file_size') final int? fileSize,
          @JsonKey(name: 'mime_type') final String? mimeType,
          @JsonKey(name: 'download_count') final int downloadCount,
          @JsonKey(name: 'published_at') final String? publishedAt,
          @JsonKey(name: 'is_published') final bool isPublished}) =
      _$SermonModelImpl;
  const _SermonModel._() : super._();

  factory _SermonModel.fromJson(Map<String, dynamic> json) =
      _$SermonModelImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  String? get description;
  @override
  @JsonKey(name: 'preacher_name')
  String get preacherName;
  @override
  @JsonKey(name: 'file_name')
  String? get fileName;
  @override
  @JsonKey(name: 'file_size')
  int? get fileSize;
  @override
  @JsonKey(name: 'mime_type')
  String? get mimeType;
  @override
  @JsonKey(name: 'download_count')
  int get downloadCount;
  @override
  @JsonKey(name: 'published_at')
  String? get publishedAt;
  @override
  @JsonKey(name: 'is_published')
  bool get isPublished;

  /// Create a copy of SermonModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SermonModelImplCopyWith<_$SermonModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
