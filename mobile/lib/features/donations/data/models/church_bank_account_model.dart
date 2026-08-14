import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/church_bank_account.dart';

part 'church_bank_account_model.freezed.dart';
part 'church_bank_account_model.g.dart';

@freezed
class ChurchBankAccountModel with _$ChurchBankAccountModel {
  const factory ChurchBankAccountModel({
    required int id,
    @JsonKey(name: 'bank_name') required String bankName,
    @JsonKey(name: 'account_number') required String accountNumber,
    @JsonKey(name: 'account_holder_name') required String accountHolderName,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'display_order') required int displayOrder,
  }) = _ChurchBankAccountModel;

  const ChurchBankAccountModel._();

  factory ChurchBankAccountModel.fromJson(Map<String, dynamic> json) =>
      _$ChurchBankAccountModelFromJson(json);

  ChurchBankAccount toEntity() {
    return ChurchBankAccount(
      id: id,
      bankName: bankName,
      accountNumber: accountNumber,
      accountHolderName: accountHolderName,
      isActive: isActive,
      displayOrder: displayOrder,
    );
  }
}
