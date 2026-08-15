import 'package:church_management_mobile/features/directory/domain/entities/member_directory_item.dart';

class UserProfile {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final List<String> roles;
  final MemberDirectoryItem? member;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    required this.roles,
    this.member,
  });

  bool get hasLinkedMember => member != null;
}
