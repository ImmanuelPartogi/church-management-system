import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/service_form_application.dart';
import 'service_form_document_model.dart';
import 'service_form_type_model.dart';

part 'service_form_application_model.freezed.dart';
part 'service_form_application_model.g.dart';

@freezed
class ServiceFormApplicationModel with _$ServiceFormApplicationModel {
  const factory ServiceFormApplicationModel({
    required int id,
    @JsonKey(name: 'application_number') required String applicationNumber,
    @JsonKey(name: 'user_id') required int userId,
    @JsonKey(name: 'member_id') int? memberId,
    @JsonKey(name: 'service_form_type') ServiceFormTypeModel? serviceFormType,
    required String status,
    @JsonKey(name: 'applicant_notes') String? applicantNotes,
    @JsonKey(name: 'rejection_reason') String? rejectionReason,
    @JsonKey(name: 'payment_status') required String paymentStatus,
    @JsonKey(name: 'payment_notes') String? paymentNotes,
    @JsonKey(name: 'reviewed_at') String? reviewedAt,
    @Default([]) List<ServiceFormDocumentModel> documents,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
  }) = _ServiceFormApplicationModel;

  const ServiceFormApplicationModel._();

  factory ServiceFormApplicationModel.fromJson(Map<String, dynamic> json) =>
      _$ServiceFormApplicationModelFromJson(json);

  ServiceFormApplication toEntity() {
    return ServiceFormApplication(
      id: id,
      applicationNumber: applicationNumber,
      userId: userId,
      memberId: memberId,
      serviceFormType: serviceFormType?.toEntity(),
      status: status,
      applicantNotes: applicantNotes,
      rejectionReason: rejectionReason,
      paymentStatus: paymentStatus,
      paymentNotes: paymentNotes,
      reviewedAt: reviewedAt,
      documents: documents.map((d) => d.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
