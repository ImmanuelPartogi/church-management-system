import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/warta.dart';

abstract class WartaRepository {
  Future<Either<Failure, List<Warta>>> getWartas({int page = 1});
  Future<Either<Failure, Warta>> getWartaDetail(int id);
  Future<Either<Failure, File>> downloadWarta(
    int id,
    String savePath, {
    void Function(int count, int total)? onProgress,
  });
}
