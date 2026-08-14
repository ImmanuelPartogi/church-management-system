import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/church_bank_account.dart';
import '../../domain/entities/donation_confirmation.dart';
import '../../domain/repositories/donation_repository.dart';
import '../datasource/donation_remote_datasource.dart';

final donationRepositoryProvider = Provider<DonationRepository>((ref) {
  final remoteDataSource = ref.watch(donationRemoteDataSourceProvider);
  return DonationRepositoryImpl(remoteDataSource);
});

class DonationRepositoryImpl implements DonationRepository {
  final DonationRemoteDataSource _remoteDataSource;

  DonationRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<ChurchBankAccount>>>
      getChurchBankAccounts() async {
    try {
      final models = await _remoteDataSource.getChurchBankAccounts();
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
        ServerFailure(
          'Gagal mengambil daftar rekening gereja: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<DonationConfirmation>>> getMyDonations({
    int page = 1,
  }) async {
    try {
      final models = await _remoteDataSource.getMyDonations(page: page);
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
        ServerFailure('Gagal mengambil riwayat donasi: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, DonationConfirmation>> getDonationDetail(
    int id,
  ) async {
    try {
      final model = await _remoteDataSource.getDonationDetail(id);
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
        ServerFailure('Gagal mengambil detail donasi: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, DonationConfirmation>> submitDonationConfirmation({
    required int chartOfAccountId,
    required num amount,
    required String transferDate,
    required String senderBank,
    String? depositorPhone,
    String? notes,
    String? proofFilePath,
    void Function(int count, int total)? onSendProgress,
  }) async {
    try {
      final model = await _remoteDataSource.submitDonationConfirmation(
        chartOfAccountId: chartOfAccountId,
        amount: amount,
        transferDate: transferDate,
        senderBank: senderBank,
        depositorPhone: depositorPhone,
        notes: notes,
        proofFilePath: proofFilePath,
        onSendProgress: onSendProgress,
      );
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
        ServerFailure('Gagal mengirimkan konfirmasi donasi: ${e.toString()}'),
      );
    }
  }
}
