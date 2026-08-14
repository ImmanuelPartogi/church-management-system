import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/selected_document.dart';
import '../../domain/entities/service_form_application.dart';
import '../../domain/entities/service_form_type.dart';
import '../../domain/repositories/service_forms_repository.dart';
import '../datasource/service_forms_remote_datasource.dart';

final serviceFormsRepositoryProvider = Provider<ServiceFormsRepository>((ref) {
  final remoteDataSource = ref.watch(serviceFormsRemoteDataSourceProvider);
  return ServiceFormsRepositoryImpl(remoteDataSource);
});

class ServiceFormsRepositoryImpl implements ServiceFormsRepository {
  final ServiceFormsRemoteDataSource _remoteDataSource;

  ServiceFormsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<ServiceFormType>>> getServiceFormTypes() async {
    try {
      final models = await _remoteDataSource.getServiceFormTypes();
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      return Left(ServerFailure(
        apiException.message,
        statusCode: apiException.statusCode,
      ),);
    } catch (e) {
      return Left(
        ServerFailure('Gagal mengambil daftar formulir: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, ServiceFormType>> getServiceFormType(int id) async {
    try {
      final model = await _remoteDataSource.getServiceFormType(id);
      return Right(model.toEntity());
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      return Left(ServerFailure(
        apiException.message,
        statusCode: apiException.statusCode,
      ),);
    } catch (e) {
      return Left(
        ServerFailure('Gagal mengambil detail formulir: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<ServiceFormApplication>>> getApplications({
    int page = 1,
  }) async {
    try {
      final models = await _remoteDataSource.getApplications(page: page);
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      return Left(ServerFailure(
        apiException.message,
        statusCode: apiException.statusCode,
      ),);
    } catch (e) {
      return Left(
        ServerFailure('Gagal mengambil riwayat permohonan: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, ServiceFormApplication>> getApplication(
    int id,
  ) async {
    try {
      final model = await _remoteDataSource.getApplication(id);
      return Right(model.toEntity());
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      return Left(ServerFailure(
        apiException.message,
        statusCode: apiException.statusCode,
      ),);
    } catch (e) {
      return Left(
        ServerFailure('Gagal mengambil detail permohonan: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, ServiceFormApplication>> submitApplication({
    required int serviceFormTypeId,
    String? applicantNotes,
    required List<SelectedDocument> documents,
  }) async {
    try {
      final model = await _remoteDataSource.submitApplication(
        serviceFormTypeId: serviceFormTypeId,
        applicantNotes: applicantNotes,
        documents: documents,
      );
      return Right(model.toEntity());
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      return Left(ServerFailure(
        apiException.message,
        statusCode: apiException.statusCode,
      ),);
    } catch (e) {
      return Left(
        ServerFailure('Gagal mengirimkan permohonan: ${e.toString()}'),
      );
    }
  }
}
