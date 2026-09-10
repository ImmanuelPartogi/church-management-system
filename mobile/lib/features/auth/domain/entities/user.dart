class UserChurchMembership {
  final int churchId;
  final String? churchUuid;
  final String churchName;
  final String churchSlug;
  final String role;

  const UserChurchMembership({
    required this.churchId,
    this.churchUuid,
    required this.churchName,
    required this.churchSlug,
    required this.role,
  });
}

class User {
  final int id;
  final String name;
  final String email;
  final bool isSuperAdmin;
  final List<String> roles;
  final List<UserChurchMembership> memberships;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.isSuperAdmin = false,
    required this.roles,
    this.memberships = const [],
  });

  bool get isAdmin =>
      isSuperAdmin ||
      roles.contains('admin') ||
      roles.contains('super_admin') ||
      roles.contains('church_admin');
  bool get isMember => roles.contains('member');
}

