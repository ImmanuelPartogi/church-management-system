import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_exception.dart';
import '../datasource/home_remote_datasource.dart';
import '../../domain/entities/daily_verse.dart';
import '../../domain/repositories/home_repository.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final remoteDataSource = ref.watch(homeRemoteDataSourceProvider);
  return HomeRepositoryImpl(remoteDataSource);
});

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remoteDataSource;

  HomeRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, DailyVerse>> getDailyVerse() async {
    try {
      final model = await _remoteDataSource.getDailyVerse();
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
        ServerFailure('Gagal mengambil ayat harian: ${e.toString()}'),
      );
    }
  }
}
