import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/church_servant.dart';
import '../../domain/repositories/servant_repository.dart';
import '../datasource/servant_remote_datasource.dart';

final servantRepositoryProvider = Provider<ServantRepository>((ref) {
  final remoteDataSource = ref.watch(servantRemoteDataSourceProvider);
  return ServantRepositoryImpl(remoteDataSource);
});

class ServantRepositoryImpl implements ServantRepository {
  final ServantRemoteDataSource _remoteDataSource;

  ServantRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<ChurchServant>>> getServants({
    String? search,
    String? role,
    int? sectorId,
    int page = 1,
  }) async {
    try {
      final models = await _remoteDataSource.getServants(
        search: search,
        role: role,
        sectorId: sectorId,
        page: page,
      );
      return Right(models.map((m) => m.toEntity()).toList());
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
        ServerFailure('Gagal memuat direktori pelayan: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, ChurchServant>> getServantDetail(int id) async {
    try {
      final model = await _remoteDataSource.getServantDetail(id);
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
        ServerFailure('Gagal memuat profil pelayan: ${e.toString()}'),
      );
    }
  }
}
