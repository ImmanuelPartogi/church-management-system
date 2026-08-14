import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/service_form_type.dart';

part 'service_form_type_model.freezed.dart';
part 'service_form_type_model.g.dart';

@freezed
class ServiceFormTypeModel with _$ServiceFormTypeModel {
  const factory ServiceFormTypeModel({
    required int id,
    required String name,
    required String slug,
    String? description,
    @JsonKey(name: 'fee_amount') required num feeAmount,
    required bool active,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _ServiceFormTypeModel;

  const ServiceFormTypeModel._();

  factory ServiceFormTypeModel.fromJson(Map<String, dynamic> json) =>
      _$ServiceFormTypeModelFromJson(json);

  ServiceFormType toEntity() {
    return ServiceFormType(
      id: id,
      name: name,
      slug: slug,
      description: description,
      feeAmount: feeAmount,
      active: active,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
