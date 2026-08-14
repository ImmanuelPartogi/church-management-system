class MemberDetail {
  final int id;
  final String? membershipNumber;
  final String fullName;
  final String? gender;
  final String? birthDate;
  final String? phone;
  final String? email;
  final String? address;
  final String? baptismDate;
  final String? status;
  final bool hasAppAccount;

  const MemberDetail({
    required this.id,
    this.membershipNumber,
    required this.fullName,
    this.gender,
    this.birthDate,
    this.phone,
    this.email,
    this.address,
    this.baptismDate,
    this.status,
    required this.hasAppAccount,
  });
}
