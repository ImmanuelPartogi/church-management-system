import 'package:fpdart/fpdart.dart';
import 'package:church_management_mobile/core/error/failures.dart';
import 'package:church_management_mobile/features/search/domain/entities/global_search_result.dart';

abstract class SearchRepository {
  Future<Either<Failure, GlobalSearchResult>> search(String query);
}
