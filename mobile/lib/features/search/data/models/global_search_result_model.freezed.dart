// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'global_search_result_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GlobalSearchResultModel {
  String get query => throw _privateConstructorUsedError;
  List<MemberDirectoryModel> get members => throw _privateConstructorUsedError;
  List<ChurchServantModel> get servants => throw _privateConstructorUsedError;
  List<SermonModel> get sermons => throw _privateConstructorUsedError;
  List<SongModel> get hymns => throw _privateConstructorUsedError;
  List<WartaModel> get wartas => throw _privateConstructorUsedError;
  List<AnnouncementModel> get announcements =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'total_count')
  int? get totalCount => throw _privateConstructorUsedError;

  /// Create a copy of GlobalSearchResultModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GlobalSearchResultModelCopyWith<GlobalSearchResultModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GlobalSearchResultModelCopyWith<$Res> {
  factory $GlobalSearchResultModelCopyWith(GlobalSearchResultModel value,
          $Res Function(GlobalSearchResultModel) then) =
      _$GlobalSearchResultModelCopyWithImpl<$Res, GlobalSearchResultModel>;
  @useResult
  $Res call(
      {String query,
      List<MemberDirectoryModel> members,
      List<ChurchServantModel> servants,
      List<SermonModel> sermons,
      List<SongModel> hymns,
      List<WartaModel> wartas,
      List<AnnouncementModel> announcements,
      @JsonKey(name: 'total_count') int? totalCount});
}

/// @nodoc
class _$GlobalSearchResultModelCopyWithImpl<$Res,
        $Val extends GlobalSearchResultModel>
    implements $GlobalSearchResultModelCopyWith<$Res> {
  _$GlobalSearchResultModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GlobalSearchResultModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? members = null,
    Object? servants = null,
    Object? sermons = null,
    Object? hymns = null,
    Object? wartas = null,
    Object? announcements = null,
    Object? totalCount = freezed,
  }) {
    return _then(_value.copyWith(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      members: null == members
          ? _value.members
          : members // ignore: cast_nullable_to_non_nullable
              as List<MemberDirectoryModel>,
      servants: null == servants
          ? _value.servants
          : servants // ignore: cast_nullable_to_non_nullable
              as List<ChurchServantModel>,
      sermons: null == sermons
          ? _value.sermons
          : sermons // ignore: cast_nullable_to_non_nullable
              as List<SermonModel>,
      hymns: null == hymns
          ? _value.hymns
          : hymns // ignore: cast_nullable_to_non_nullable
              as List<SongModel>,
      wartas: null == wartas
          ? _value.wartas
          : wartas // ignore: cast_nullable_to_non_nullable
              as List<WartaModel>,
      announcements: null == announcements
          ? _value.announcements
          : announcements // ignore: cast_nullable_to_non_nullable
              as List<AnnouncementModel>,
      totalCount: freezed == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GlobalSearchResultModelImplCopyWith<$Res>
    implements $GlobalSearchResultModelCopyWith<$Res> {
  factory _$$GlobalSearchResultModelImplCopyWith(
          _$GlobalSearchResultModelImpl value,
          $Res Function(_$GlobalSearchResultModelImpl) then) =
      __$$GlobalSearchResultModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String query,
      List<MemberDirectoryModel> members,
      List<ChurchServantModel> servants,
      List<SermonModel> sermons,
      List<SongModel> hymns,
      List<WartaModel> wartas,
      List<AnnouncementModel> announcements,
      @JsonKey(name: 'total_count') int? totalCount});
}

/// @nodoc
class __$$GlobalSearchResultModelImplCopyWithImpl<$Res>
    extends _$GlobalSearchResultModelCopyWithImpl<$Res,
        _$GlobalSearchResultModelImpl>
    implements _$$GlobalSearchResultModelImplCopyWith<$Res> {
  __$$GlobalSearchResultModelImplCopyWithImpl(
      _$GlobalSearchResultModelImpl _value,
      $Res Function(_$GlobalSearchResultModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of GlobalSearchResultModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? members = null,
    Object? servants = null,
    Object? sermons = null,
    Object? hymns = null,
    Object? wartas = null,
    Object? announcements = null,
    Object? totalCount = freezed,
  }) {
    return _then(_$GlobalSearchResultModelImpl(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      members: null == members
          ? _value._members
          : members // ignore: cast_nullable_to_non_nullable
              as List<MemberDirectoryModel>,
      servants: null == servants
          ? _value._servants
          : servants // ignore: cast_nullable_to_non_nullable
              as List<ChurchServantModel>,
      sermons: null == sermons
          ? _value._sermons
          : sermons // ignore: cast_nullable_to_non_nullable
              as List<SermonModel>,
      hymns: null == hymns
          ? _value._hymns
          : hymns // ignore: cast_nullable_to_non_nullable
              as List<SongModel>,
      wartas: null == wartas
          ? _value._wartas
          : wartas // ignore: cast_nullable_to_non_nullable
              as List<WartaModel>,
      announcements: null == announcements
          ? _value._announcements
          : announcements // ignore: cast_nullable_to_non_nullable
              as List<AnnouncementModel>,
      totalCount: freezed == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$GlobalSearchResultModelImpl extends _GlobalSearchResultModel {
  const _$GlobalSearchResultModelImpl(
      {required this.query,
      final List<MemberDirectoryModel> members = const [],
      final List<ChurchServantModel> servants = const [],
      final List<SermonModel> sermons = const [],
      final List<SongModel> hymns = const [],
      final List<WartaModel> wartas = const [],
      final List<AnnouncementModel> announcements = const [],
      @JsonKey(name: 'total_count') this.totalCount})
      : _members = members,
        _servants = servants,
        _sermons = sermons,
        _hymns = hymns,
        _wartas = wartas,
        _announcements = announcements,
        super._();

  @override
  final String query;
  final List<MemberDirectoryModel> _members;
  @override
  @JsonKey()
  List<MemberDirectoryModel> get members {
    if (_members is EqualUnmodifiableListView) return _members;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_members);
  }

  final List<ChurchServantModel> _servants;
  @override
  @JsonKey()
  List<ChurchServantModel> get servants {
    if (_servants is EqualUnmodifiableListView) return _servants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_servants);
  }

  final List<SermonModel> _sermons;
  @override
  @JsonKey()
  List<SermonModel> get sermons {
    if (_sermons is EqualUnmodifiableListView) return _sermons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sermons);
  }

  final List<SongModel> _hymns;
  @override
  @JsonKey()
  List<SongModel> get hymns {
    if (_hymns is EqualUnmodifiableListView) return _hymns;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_hymns);
  }

  final List<WartaModel> _wartas;
  @override
  @JsonKey()
  List<WartaModel> get wartas {
    if (_wartas is EqualUnmodifiableListView) return _wartas;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_wartas);
  }

  final List<AnnouncementModel> _announcements;
  @override
  @JsonKey()
  List<AnnouncementModel> get announcements {
    if (_announcements is EqualUnmodifiableListView) return _announcements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_announcements);
  }

  @override
  @JsonKey(name: 'total_count')
  final int? totalCount;

  @override
  String toString() {
    return 'GlobalSearchResultModel(query: $query, members: $members, servants: $servants, sermons: $sermons, hymns: $hymns, wartas: $wartas, announcements: $announcements, totalCount: $totalCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GlobalSearchResultModelImpl &&
            (identical(other.query, query) || other.query == query) &&
            const DeepCollectionEquality().equals(other._members, _members) &&
            const DeepCollectionEquality().equals(other._servants, _servants) &&
            const DeepCollectionEquality().equals(other._sermons, _sermons) &&
            const DeepCollectionEquality().equals(other._hymns, _hymns) &&
            const DeepCollectionEquality().equals(other._wartas, _wartas) &&
            const DeepCollectionEquality()
                .equals(other._announcements, _announcements) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      query,
      const DeepCollectionEquality().hash(_members),
      const DeepCollectionEquality().hash(_servants),
      const DeepCollectionEquality().hash(_sermons),
      const DeepCollectionEquality().hash(_hymns),
      const DeepCollectionEquality().hash(_wartas),
      const DeepCollectionEquality().hash(_announcements),
      totalCount);

  /// Create a copy of GlobalSearchResultModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GlobalSearchResultModelImplCopyWith<_$GlobalSearchResultModelImpl>
      get copyWith => __$$GlobalSearchResultModelImplCopyWithImpl<
          _$GlobalSearchResultModelImpl>(this, _$identity);
}

abstract class _GlobalSearchResultModel extends GlobalSearchResultModel {
  const factory _GlobalSearchResultModel(
          {required final String query,
          final List<MemberDirectoryModel> members,
          final List<ChurchServantModel> servants,
          final List<SermonModel> sermons,
          final List<SongModel> hymns,
          final List<WartaModel> wartas,
          final List<AnnouncementModel> announcements,
          @JsonKey(name: 'total_count') final int? totalCount}) =
      _$GlobalSearchResultModelImpl;
  const _GlobalSearchResultModel._() : super._();

  @override
  String get query;
  @override
  List<MemberDirectoryModel> get members;
  @override
  List<ChurchServantModel> get servants;
  @override
  List<SermonModel> get sermons;
  @override
  List<SongModel> get hymns;
  @override
  List<WartaModel> get wartas;
  @override
  List<AnnouncementModel> get announcements;
  @override
  @JsonKey(name: 'total_count')
  int? get totalCount;

  /// Create a copy of GlobalSearchResultModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GlobalSearchResultModelImplCopyWith<_$GlobalSearchResultModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
