class ChartOfAccount {
  final int id;
  final String code;
  final String name;
  final String type;
  final String? description;
  final bool isActive;

  const ChartOfAccount({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    this.description,
    required this.isActive,
  });
}
