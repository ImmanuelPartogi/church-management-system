import 'service_form_document.dart';
import 'service_form_type.dart';

class ServiceFormApplication {
  final int id;
  final String applicationNumber;
  final int userId;
  final int? memberId;
  final ServiceFormType? serviceFormType;
  final String status;
  final String? applicantNotes;
  final String? rejectionReason;
  final String paymentStatus;
  final String? paymentNotes;
  final String? reviewedAt;
  final List<ServiceFormDocument> documents;
  final String createdAt;
  final String updatedAt;

  const ServiceFormApplication({
    required this.id,
    required this.applicationNumber,
    required this.userId,
    this.memberId,
    this.serviceFormType,
    required this.status,
    this.applicantNotes,
    this.rejectionReason,
    required this.paymentStatus,
    this.paymentNotes,
    this.reviewedAt,
    required this.documents,
    required this.createdAt,
    required this.updatedAt,
  });
}
