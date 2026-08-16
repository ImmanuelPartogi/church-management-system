import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:church_management_mobile/features/directory/data/models/member_directory_model.dart';
import 'package:church_management_mobile/features/profile/domain/entities/user_profile.dart';

part 'user_profile_model.freezed.dart';

@freezed
class UserProfileModel with _$UserProfileModel {
  const UserProfileModel._();

  const factory UserProfileModel({
    required int id,
    required String name,
    required String email,
    String? phone,
    String? address,
    @Default([]) List<String> roles,
    MemberDirectoryModel? member,
  }) = _UserProfileModel;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    return UserProfileModel(
      id: data['id'] as int? ?? 0,
      name: (data['name'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      phone: data['phone'] as String?,
      address: data['address'] as String?,
      roles: (data['roles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      member: data['member'] != null
          ? MemberDirectoryModel.fromJson(
              data['member'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  UserProfile toEntity() {
    return UserProfile(
      id: id,
      name: name,
      email: email,
      phone: phone,
      address: address,
      roles: roles,
      member: member?.toEntity(),
    );
  }
}
