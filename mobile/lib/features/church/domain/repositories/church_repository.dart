import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/church.dart';

abstract class ChurchRepository {
  Future<Either<Failure, List<Church>>> getChurches();
}
