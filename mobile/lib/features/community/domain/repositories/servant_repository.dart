import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/church_servant.dart';

abstract class ServantRepository {
  Future<Either<Failure, List<ChurchServant>>> getServants({
    String? search,
    String? role,
    int? sectorId,
    int page = 1,
  });

  Future<Either<Failure, ChurchServant>> getServantDetail(int id);
}
