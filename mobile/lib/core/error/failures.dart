import 'package:flutter/foundation.dart';

/// Representasi error yang aman ditampilkan ke UI. Repository selalu
/// mengembalikan `Either<Failure, T>` (lihat package:fpdart) alih-alih
/// melempar exception ke presentation layer.
@immutable
sealed class Failure {
  const Failure(this.message);

  final String message;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
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

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Terjadi kesalahan tak terduga.']);
}
