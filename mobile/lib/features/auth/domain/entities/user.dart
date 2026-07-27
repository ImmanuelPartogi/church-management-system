class User {
  final int id;
  final String name;
  final String email;
  final List<String> roles;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.roles,
  });

  bool get isAdmin => roles.contains('admin');
  bool get isMember => roles.contains('member');
}
