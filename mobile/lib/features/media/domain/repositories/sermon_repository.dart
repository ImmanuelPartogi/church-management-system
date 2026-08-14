import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/sermon.dart';

abstract class SermonRepository {
  Future<Either<Failure, List<Sermon>>> getSermons({
    String? search,
    int page = 1,
  });

  Future<Either<Failure, Sermon>> getSermonDetail(int id);

  Future<Either<Failure, int>> downloadSermon(int id);
}
