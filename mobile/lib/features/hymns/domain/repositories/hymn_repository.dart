import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/song.dart';
import '../entities/songbook.dart';

abstract class HymnRepository {
  Future<Either<Failure, List<Songbook>>> getSongbooks();

  Future<Either<Failure, List<Song>>> getSongs({
    String? search,
    int? songbookId,
    int page = 1,
  });

  Future<Either<Failure, Song>> getSongDetail(int id);
}
