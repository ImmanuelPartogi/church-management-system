import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/service_form_document.dart';

part 'service_form_document_model.freezed.dart';
part 'service_form_document_model.g.dart';

@freezed
class ServiceFormDocumentModel with _$ServiceFormDocumentModel {
  const factory ServiceFormDocumentModel({
    required int id,
    @JsonKey(name: 'service_form_application_id')
    required int serviceFormApplicationId,
    @JsonKey(name: 'document_name') required String documentName,
    @JsonKey(name: 'file_name') required String fileName,
    @JsonKey(name: 'mime_type') required String mimeType,
    @JsonKey(name: 'file_size') required int fileSize,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _ServiceFormDocumentModel;

  const ServiceFormDocumentModel._();

  factory ServiceFormDocumentModel.fromJson(Map<String, dynamic> json) =>
      _$ServiceFormDocumentModelFromJson(json);

  ServiceFormDocument toEntity() {
    return ServiceFormDocument(
      id: id,
      serviceFormApplicationId: serviceFormApplicationId,
      documentName: documentName,
      fileName: fileName,
      mimeType: mimeType,
      fileSize: fileSize,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
