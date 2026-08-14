class ChurchServant {
  final int id;
  final String name;
  final String role;
  final String roleLabel;
  final String? maskedPhone;
  final String? phone;
  final String? email;
  final String? description;
  final bool active;
  final String? resortName;
  final String? sectorName;
  final String? fellowshipName;

  const ChurchServant({
    required this.id,
    required this.name,
    required this.role,
    required this.roleLabel,
    this.maskedPhone,
    this.phone,
    this.email,
    this.description,
    required this.active,
    this.resortName,
    this.sectorName,
    this.fellowshipName,
  });
}
