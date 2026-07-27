import 'package:fpdart/fpdart.dart';
import '../error/failures.dart';

/// Kontrak dasar untuk seluruh usecase di domain layer.
///
/// - [Type] adalah tipe data sukses yang dikembalikan.
/// - [Params] adalah parameter input usecase; gunakan [NoParams] bila
///   usecase tidak butuh input.
///
/// Contoh implementasi (di fase pengembangan modul):
/// ```dart
/// class SubmitPrayerRequest implements UseCase<PrayerRequest, SubmitPrayerRequestParams> {
///   SubmitPrayerRequest(this._repository);
///   final PrayerRequestRepository _repository;
///
///   @override
///   Future<Either<Failure, PrayerRequest>> call(SubmitPrayerRequestParams params) {
///     return _repository.submit(params);
///   }
/// }
/// ```
abstract interface class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}
