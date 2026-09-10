import '../../domain/entities/user.dart';

class UserChurchMembershipModel {
  final int churchId;
  final String? churchUuid;
  final String churchName;
  final String churchSlug;
  final String role;

  const UserChurchMembershipModel({
    required this.churchId,
    this.churchUuid,
    required this.churchName,
    required this.churchSlug,
    required this.role,
  });

  factory UserChurchMembershipModel.fromJson(Map<String, dynamic> json) {
    return UserChurchMembershipModel(
      churchId: json['church_id'] is int
          ? json['church_id'] as int
          : int.tryParse(json['church_id']?.toString() ?? '0') ?? 0,
      churchUuid: json['church_uuid']?.toString(),
      churchName: json['church_name']?.toString() ?? '',
      churchSlug: json['church_slug']?.toString() ?? '',
      role: json['role']?.toString() ?? 'member',
    );
  }

  Map<String, dynamic> toJson() => {
        'church_id': churchId,
        'church_uuid': churchUuid,
        'church_name': churchName,
        'church_slug': churchSlug,
        'role': role,
      };

  UserChurchMembership toEntity() => UserChurchMembership(
        churchId: churchId,
        churchUuid: churchUuid,
        churchName: churchName,
        churchSlug: churchSlug,
        role: role,
      );
}

class UserModel {
  final int id;
  final String name;
  final String email;
  final bool isSuperAdmin;
  final List<String> roles;
  final List<UserChurchMembershipModel> memberships;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.isSuperAdmin = false,
    required this.roles,
    this.memberships = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawMemberships = json['memberships'];
    List<UserChurchMembershipModel> parsedMemberships = [];
    if (rawMemberships is List) {
      parsedMemberships = rawMemberships
          .map(
            (e) => UserChurchMembershipModel.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    return UserModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      isSuperAdmin: json['is_super_admin'] == true,
      roles: (json['roles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      memberships: parsedMemberships,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'is_super_admin': isSuperAdmin,
        'roles': roles,
        'memberships': memberships.map((m) => m.toJson()).toList(),
      };

  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      isSuperAdmin: isSuperAdmin,
      roles: roles,
      memberships: memberships.map((m) => m.toEntity()).toList(),
    );
  }
}
