import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/selected_document.dart';
import '../entities/service_form_application.dart';
import '../entities/service_form_type.dart';

abstract class ServiceFormsRepository {
  Future<Either<Failure, List<ServiceFormType>>> getServiceFormTypes();

  Future<Either<Failure, ServiceFormType>> getServiceFormType(int id);

  Future<Either<Failure, List<ServiceFormApplication>>> getApplications({
    int page = 1,
  });

  Future<Either<Failure, ServiceFormApplication>> getApplication(int id);

  Future<Either<Failure, ServiceFormApplication>> submitApplication({
    required int serviceFormTypeId,
    String? applicantNotes,
    required List<SelectedDocument> documents,
  });
}
