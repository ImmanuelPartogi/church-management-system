import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/member_detail.dart';

part 'member_detail_model.freezed.dart';
part 'member_detail_model.g.dart';

@freezed
class MemberDetailModel with _$MemberDetailModel {
  const factory MemberDetailModel({
    required int id,
    @JsonKey(name: 'membership_number') String? membershipNumber,
    @JsonKey(name: 'full_name') required String fullName,
    String? gender,
    @JsonKey(name: 'birth_date') String? birthDate,
    String? phone,
    String? email,
    String? address,
    @JsonKey(name: 'baptism_date') String? baptismDate,
    String? status,
    @JsonKey(name: 'has_app_account') @Default(false) bool hasAppAccount,
  }) = _MemberDetailModel;

  const MemberDetailModel._();

  factory MemberDetailModel.fromJson(Map<String, dynamic> json) =>
      _$MemberDetailModelFromJson(json);

  MemberDetail toEntity() => MemberDetail(
        id: id,
        membershipNumber: membershipNumber,
        fullName: fullName,
        gender: gender,
        birthDate: birthDate,
        phone: phone,
        email: email,
        address: address,
        baptismDate: baptismDate,
        status: status,
        hasAppAccount: hasAppAccount,
      );
}
