import 'package:flutter/foundation.dart';

@immutable
sealed class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  final int? statusCode;
  final dynamic errors;

  const ServerFailure(super.message, {this.statusCode, this.errors});
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Tidak ada koneksi internet.']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([
    super.message = 'Sesi berakhir, silakan login kembali.',
  ]);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {this.errors});

  final Map<String, List<String>>? errors;
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Gagal membaca data lokal.']);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Terjadi kesalahan tak terduga.']);
}

class ModuleDisabledFailure extends Failure {
  final String? module;

  const ModuleDisabledFailure(super.message, {this.module});
}

class TenantMismatchFailure extends Failure {
  const TenantMismatchFailure([
    super.message =
        'Unauthorized tenant access: You are not an active member of this church.',
  ]);
}

class NoActiveMembershipFailure extends Failure {
  const NoActiveMembershipFailure([
    super.message = 'User has no active church membership.',
  ]);
}
