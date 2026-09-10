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
      ModuleDisabledException(:final message, :final module) =>
        ModuleDisabledFailure(message, module: module),
      TenantMismatchException() => const TenantMismatchFailure(),
      NoActiveMembershipException() => const NoActiveMembershipFailure(),
    };
  }

  static Failure fromDioException(dynamic e) {
    if (e is! Exception) {
      return UnknownFailure(e.toString());
    }

    // Dynamic extraction if DioException is passed
    try {
      final dynamic response = (e as dynamic).response;
      if (response?.data != null && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final code = data['code']?.toString();
        final message = data['message']?.toString() ?? 'Terjadi kesalahan';
        final module = data['module']?.toString();

        if (code == 'MODULE_DISABLED') {
          return ModuleDisabledFailure(message, module: module);
        }
        if (code == 'TENANT_MEMBERSHIP_MISMATCH') {
          return TenantMismatchFailure(message);
        }
        if (code == 'NO_ACTIVE_MEMBERSHIP') {
          return NoActiveMembershipFailure(message);
        }
        final statusCode = (response.statusCode as num?)?.toInt();
        return ServerFailure(message, statusCode: statusCode);
      }
    } catch (_) {}

    return ServerFailure(e.toString());
  }
}
