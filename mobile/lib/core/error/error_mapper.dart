import 'exceptions.dart';
import 'failures.dart';

/// Konversi [AppException] (data layer) menjadi [Failure] (domain layer).
///
/// Dipakai di setiap repository implementation, contoh:
/// ```dart
/// try {
///   final result = await remoteDataSource.submitForm(payload);
///   return Right(result);
/// } on AppException catch (e) {
///   return Left(ErrorMapper.map(e));
/// }
/// ```
class ErrorMapper {
  const ErrorMapper._();

  static Failure map(AppException exception) {
    return switch (exception) {
      NetworkException() => NetworkFailure(exception.message),
      UnauthorizedException() => UnauthorizedFailure(exception.message),
      ValidationException(:final message, :final errors) =>
        ValidationFailure(message, errors: errors),
      ServerException() => ServerFailure(exception.message),
      CacheException() => CacheFailure(exception.message),
    };
  }
}
