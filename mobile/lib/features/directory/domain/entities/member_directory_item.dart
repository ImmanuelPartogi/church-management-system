class MemberDirectoryItem {
  final int id;
  final String? membershipNumber;
  final String fullName;
  final String? gender;
  final String? status;
  final String? maskedPhone;
  final bool hasAppAccount;

  const MemberDirectoryItem({
    required this.id,
    this.membershipNumber,
    required this.fullName,
    this.gender,
    this.status,
    this.maskedPhone,
    required this.hasAppAccount,
  });
}
