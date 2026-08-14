import 'package:church_management_mobile/features/directory/domain/entities/member_directory_item.dart';
import 'package:church_management_mobile/features/community/domain/entities/church_servant.dart';
import 'package:church_management_mobile/features/media/domain/entities/sermon.dart';
import 'package:church_management_mobile/features/hymns/domain/entities/song.dart';
import 'package:church_management_mobile/features/warta/domain/entities/warta.dart';
import 'package:church_management_mobile/features/announcement/domain/entities/announcement.dart';

class GlobalSearchResult {
  final String query;
  final List<MemberDirectoryItem> members;
  final List<ChurchServant> servants;
  final List<Sermon> sermons;
  final List<Song> hymns;
  final List<Warta> wartas;
  final List<Announcement> announcements;
  final int totalCount;

  const GlobalSearchResult({
    required this.query,
    required this.members,
    required this.servants,
    required this.sermons,
    required this.hymns,
    required this.wartas,
    required this.announcements,
    required this.totalCount,
  });

  bool get isEmpty => totalCount == 0;
}
