import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/church_servant.dart';

part 'church_servant_model.freezed.dart';
part 'church_servant_model.g.dart';

@freezed
class ChurchServantModel with _$ChurchServantModel {
  const factory ChurchServantModel({
    required int id,
    required String name,
    required String role,
    @JsonKey(name: 'role_label') required String roleLabel,
    @JsonKey(name: 'masked_phone') String? maskedPhone,
    String? phone,
    String? email,
    String? description,
    @Default(true) bool active,
    @JsonKey(name: 'resort_name') String? resortName,
    @JsonKey(name: 'sector_name') String? sectorName,
    @JsonKey(name: 'fellowship_name') String? fellowshipName,
  }) = _ChurchServantModel;

  const ChurchServantModel._();

  factory ChurchServantModel.fromJson(Map<String, dynamic> json) =>
      _$ChurchServantModelFromJson(json);

  ChurchServant toEntity() => ChurchServant(
        id: id,
        name: name,
        role: role,
        roleLabel: roleLabel,
        maskedPhone: maskedPhone,
        phone: phone,
        email: email,
        description: description,
        active: active,
        resortName: resortName,
        sectorName: sectorName,
        fellowshipName: fellowshipName,
      );
}
