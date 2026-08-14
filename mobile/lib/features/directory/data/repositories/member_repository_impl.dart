import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/member_detail.dart';
import '../../domain/entities/member_directory_item.dart';
import '../../domain/repositories/member_repository.dart';
import '../datasource/member_remote_datasource.dart';

final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  final remoteDataSource = ref.watch(memberRemoteDataSourceProvider);
  return MemberRepositoryImpl(remoteDataSource);
});

class MemberRepositoryImpl implements MemberRepository {
  final MemberRemoteDataSource _remoteDataSource;

  MemberRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<MemberDirectoryItem>>> searchMembers({
    String? query,
    int page = 1,
  }) async {
    try {
      final models = await _remoteDataSource.searchMembers(
        query: query,
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
        ServerFailure('Gagal memuat direktori jemaat: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, MemberDetail>> getMemberDetail(int id) async {
    try {
      final model = await _remoteDataSource.getMemberDetail(id);
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
        ServerFailure('Gagal memuat detail profil jemaat: ${e.toString()}'),
      );
    }
  }
}
