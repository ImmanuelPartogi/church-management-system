import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/financial_report.dart';

abstract class FinanceRepository {
  Future<Either<Failure, FinancialReport>> getFinancialReport({
    String? from,
    String? to,
  });
}
