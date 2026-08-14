import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/financial_report.dart';
import '../../domain/repositories/finance_repository.dart';
import '../datasource/finance_remote_datasource.dart';

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  final remoteDataSource = ref.watch(financeRemoteDataSourceProvider);
  return FinanceRepositoryImpl(remoteDataSource);
});

class FinanceRepositoryImpl implements FinanceRepository {
  final FinanceRemoteDataSource _remoteDataSource;

  FinanceRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, FinancialReport>> getFinancialReport({
    String? from,
    String? to,
  }) async {
    try {
      final model =
          await _remoteDataSource.getFinancialReport(from: from, to: to);
      return Right(model.toEntity());
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      return Left(
        ServerFailure(
          apiException.message,
          statusCode: apiException.statusCode,
        ),
      );
    } catch (e) {
      return Left(
        ServerFailure(
            'Gagal mengambil laporan transparansi keuangan: ${e.toString()}',),
      );
    }
  }
}
