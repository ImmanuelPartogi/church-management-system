import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/chart_of_account.dart';

part 'chart_of_account_model.freezed.dart';
part 'chart_of_account_model.g.dart';

@freezed
class ChartOfAccountModel with _$ChartOfAccountModel {
  const factory ChartOfAccountModel({
    required int id,
    required String code,
    required String name,
    required String type,
    String? description,
    @JsonKey(name: 'is_active') required bool isActive,
  }) = _ChartOfAccountModel;

  const ChartOfAccountModel._();

  factory ChartOfAccountModel.fromJson(Map<String, dynamic> json) =>
      _$ChartOfAccountModelFromJson(json);

  ChartOfAccount toEntity() {
    return ChartOfAccount(
      id: id,
      code: code,
      name: name,
      type: type,
      description: description,
      isActive: isActive,
    );
  }
}
