import 'package:fpdart/fpdart.dart';
import 'package:church_management_mobile/core/error/exceptions.dart';
import 'package:church_management_mobile/core/error/failures.dart';
import 'package:church_management_mobile/features/search/domain/entities/global_search_result.dart';
import 'package:church_management_mobile/features/search/domain/repositories/search_repository.dart';
import 'package:church_management_mobile/features/search/data/datasource/search_remote_datasource.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;

  SearchRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, GlobalSearchResult>> search(String query) async {
    try {
      final model = await remoteDataSource.search(query);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
