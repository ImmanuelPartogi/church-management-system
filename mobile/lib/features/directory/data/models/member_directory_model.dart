import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/member_directory_item.dart';

part 'member_directory_model.freezed.dart';
part 'member_directory_model.g.dart';

@freezed
class MemberDirectoryModel with _$MemberDirectoryModel {
  const factory MemberDirectoryModel({
    required int id,
    @JsonKey(name: 'membership_number') String? membershipNumber,
    @JsonKey(name: 'full_name') required String fullName,
    String? gender,
    String? status,
    @JsonKey(name: 'masked_phone') String? maskedPhone,
    @JsonKey(name: 'has_app_account') @Default(false) bool hasAppAccount,
  }) = _MemberDirectoryModel;

  const MemberDirectoryModel._();

  factory MemberDirectoryModel.fromJson(Map<String, dynamic> json) =>
      _$MemberDirectoryModelFromJson(json);

  MemberDirectoryItem toEntity() => MemberDirectoryItem(
        id: id,
        membershipNumber: membershipNumber,
        fullName: fullName,
        gender: gender,
        status: status,
        maskedPhone: maskedPhone,
        hasAppAccount: hasAppAccount,
      );
}
