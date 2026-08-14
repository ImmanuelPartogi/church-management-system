import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/member_detail.dart';
import '../entities/member_directory_item.dart';

abstract class MemberRepository {
  Future<Either<Failure, List<MemberDirectoryItem>>> searchMembers({
    String? query,
    int page = 1,
  });

  Future<Either<Failure, MemberDetail>> getMemberDetail(int id);
}
