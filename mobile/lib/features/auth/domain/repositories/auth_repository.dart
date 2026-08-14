import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signInWithEmailAndPassword(
    String email,
    String password,
  );
  Future<Either<Failure, User>> signInWithGoogle();
  Future<Either<Failure, User>> loginWithFirebaseToken(String firebaseIdToken);
  Future<Either<Failure, User>> getCurrentUser();
  Future<Either<Failure, void>> logout();
}
