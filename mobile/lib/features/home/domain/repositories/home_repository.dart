import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/daily_verse.dart';

abstract class HomeRepository {
  Future<Either<Failure, DailyVerse>> getDailyVerse();
}
