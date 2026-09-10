/// Exception yang dilempar di data layer (datasource), lalu ditangkap
/// di repository dan dikonversi menjadi [Failure] untuk domain/presentation.
sealed class AppException implements Exception {
  const AppException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;
}

class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Tidak ada koneksi internet.']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([
    super.message = 'Sesi berakhir, silakan login kembali.',
  ]) : super(statusCode: 401);
}

class ValidationException extends AppException {
  const ValidationException(super.message, {this.errors})
      : super(statusCode: 422);

  /// Error per-field, mengikuti format Laravel validation error.
  final Map<String, List<String>>? errors;
}

class CacheException extends AppException {
  const CacheException([super.message = 'Gagal membaca data lokal.']);
}

class ModuleDisabledException extends AppException {
  final String? module;

  const ModuleDisabledException(
    super.message, {
    this.module,
    super.statusCode = 403,
  });
}

class TenantMismatchException extends AppException {
  const TenantMismatchException([
    super.message =
        'Unauthorized tenant access: You are not an active member of this church.',
  ]) : super(statusCode: 403);
}

class NoActiveMembershipException extends AppException {
  const NoActiveMembershipException([
    super.message = 'User has no active church membership.',
  ]) : super(statusCode: 403);
}
