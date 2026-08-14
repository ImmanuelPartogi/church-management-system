import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/prayer_request.dart';

abstract class PrayerRequestRepository {
  Future<Either<Failure, List<PrayerRequest>>> getMyPrayerRequests({
    int page = 1,
  });

  Future<Either<Failure, PrayerRequest>> getPrayerRequestDetail(int id);

  Future<Either<Failure, PrayerRequest>> submitPrayerRequest({
    required String title,
    required String content,
    String? category,
    bool isPrivate = true,
  });
}
