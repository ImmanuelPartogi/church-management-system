import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/service_forms_repository_impl.dart';
import '../../domain/entities/selected_document.dart';
import '../../domain/entities/service_form_application.dart';
import '../../domain/entities/service_form_type.dart';
import '../../domain/repositories/service_forms_repository.dart';

final serviceFormTypesProvider =
    FutureProvider<List<ServiceFormType>>((ref) async {
  final repository = ref.watch(serviceFormsRepositoryProvider);
  final result = await repository.getServiceFormTypes();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (list) => list,
  );
});

final serviceFormTypeDetailProvider =
    FutureProvider.family<ServiceFormType, int>((ref, id) async {
  final repository = ref.watch(serviceFormsRepositoryProvider);
  final result = await repository.getServiceFormType(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (type) => type,
  );
});

final serviceFormApplicationsProvider =
    FutureProvider<List<ServiceFormApplication>>((ref) async {
  final repository = ref.watch(serviceFormsRepositoryProvider);
  final result = await repository.getApplications(page: 1);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (list) => list,
  );
});

final serviceFormApplicationDetailProvider =
    FutureProvider.family<ServiceFormApplication, int>((ref, id) async {
  final repository = ref.watch(serviceFormsRepositoryProvider);
  final result = await repository.getApplication(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (app) => app,
  );
});

enum SubmissionStatus { idle, submitting, success, error }

class FormSubmissionState {
  final SubmissionStatus status;
  final ServiceFormApplication? submittedApplication;
  final String? errorMessage;

  const FormSubmissionState({
    required this.status,
    this.submittedApplication,
    this.errorMessage,
  });

  const FormSubmissionState.initial() : this(status: SubmissionStatus.idle);
}

class ServiceFormSubmissionNotifier extends StateNotifier<FormSubmissionState> {
  final ServiceFormsRepository _repository;

  ServiceFormSubmissionNotifier(this._repository)
      : super(const FormSubmissionState.initial());

  Future<void> submit({
    required int serviceFormTypeId,
    String? applicantNotes,
    required List<SelectedDocument> documents,
  }) async {
    state = const FormSubmissionState(status: SubmissionStatus.submitting);

    final result = await _repository.submitApplication(
      serviceFormTypeId: serviceFormTypeId,
      applicantNotes: applicantNotes,
      documents: documents,
    );

    result.fold(
      (failure) {
        state = FormSubmissionState(
          status: SubmissionStatus.error,
          errorMessage: failure.message,
        );
      },
      (application) {
        state = FormSubmissionState(
          status: SubmissionStatus.success,
          submittedApplication: application,
        );
      },
    );
  }

  void reset() {
    state = const FormSubmissionState.initial();
  }
}

final serviceFormSubmissionProvider =
    StateNotifierProvider<ServiceFormSubmissionNotifier, FormSubmissionState>(
        (ref) {
  final repository = ref.watch(serviceFormsRepositoryProvider);
  return ServiceFormSubmissionNotifier(repository);
});
