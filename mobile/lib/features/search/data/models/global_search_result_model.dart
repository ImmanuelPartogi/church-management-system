import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:church_management_mobile/features/directory/data/models/member_directory_model.dart';
import 'package:church_management_mobile/features/community/data/models/church_servant_model.dart';
import 'package:church_management_mobile/features/media/data/models/sermon_model.dart';
import 'package:church_management_mobile/features/hymns/data/models/song_model.dart';
import 'package:church_management_mobile/features/warta/data/models/warta_model.dart';
import 'package:church_management_mobile/features/announcement/data/models/announcement_model.dart';
import 'package:church_management_mobile/features/search/domain/entities/global_search_result.dart';

part 'global_search_result_model.freezed.dart';

@freezed
class GlobalSearchResultModel with _$GlobalSearchResultModel {
  const GlobalSearchResultModel._();

  const factory GlobalSearchResultModel({
    required String query,
    @Default([]) List<MemberDirectoryModel> members,
    @Default([]) List<ChurchServantModel> servants,
    @Default([]) List<SermonModel> sermons,
    @Default([]) List<SongModel> hymns,
    @Default([]) List<WartaModel> wartas,
    @Default([]) List<AnnouncementModel> announcements,
    @JsonKey(name: 'total_count') int? totalCount,
  }) = _GlobalSearchResultModel;

  factory GlobalSearchResultModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final results = data['results'] as Map<String, dynamic>? ?? {};
    final meta = data['meta'] as Map<String, dynamic>? ?? {};

    return GlobalSearchResultModel(
      query: (data['query'] as String?) ?? '',
      members: (results['members'] as List<dynamic>?)
              ?.map(
                (e) => MemberDirectoryModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      servants: (results['servants'] as List<dynamic>?)
              ?.map(
                (e) => ChurchServantModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      sermons: (results['sermons'] as List<dynamic>?)
              ?.map((e) => SermonModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      hymns: (results['hymns'] as List<dynamic>?)
              ?.map((e) => SongModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      wartas: (results['wartas'] as List<dynamic>?)
              ?.map((e) => WartaModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      announcements: (results['announcements'] as List<dynamic>?)
              ?.map(
                (e) => AnnouncementModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      totalCount: meta['total'] as int? ?? 0,
    );
  }

  GlobalSearchResult toEntity() {
    return GlobalSearchResult(
      query: query,
      members: members.map((e) => e.toEntity()).toList(),
      servants: servants.map((e) => e.toEntity()).toList(),
      sermons: sermons.map((e) => e.toEntity()).toList(),
      hymns: hymns.map((e) => e.toEntity()).toList(),
      wartas: wartas.map((e) => e.toEntity()).toList(),
      announcements: announcements.map((e) => e.toEntity()).toList(),
      totalCount: totalCount ??
          (members.length +
              servants.length +
              sermons.length +
              hymns.length +
              wartas.length +
              announcements.length),
    );
  }
}
