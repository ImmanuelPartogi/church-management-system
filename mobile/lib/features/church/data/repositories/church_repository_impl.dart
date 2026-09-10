import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/church.dart';
import '../../domain/repositories/church_repository.dart';
import '../datasource/church_remote_datasource.dart';

final churchRepositoryProvider = Provider<ChurchRepository>((ref) {
  final remoteDataSource = ref.watch(churchRemoteDataSourceProvider);
  return ChurchRepositoryImpl(remoteDataSource);
});

class ChurchRepositoryImpl implements ChurchRepository {
  final ChurchRemoteDataSource _remoteDataSource;

  ChurchRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Church>>> getChurches() async {
    try {
      final models = await _remoteDataSource.getChurches();
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      return Left(ServerFailure('Gagal mengambil daftar gereja: ${e.toString()}'));
    }
  }
}
