import 'package:fpdart/fpdart.dart';
import 'package:church_management_mobile/core/error/failures.dart';
import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getProfile();
  Future<Either<Failure, UserProfile>> updateProfile({
    required String name,
    String? phone,
    String? address,
  });
  Future<Either<Failure, void>> deleteAccount();
}
