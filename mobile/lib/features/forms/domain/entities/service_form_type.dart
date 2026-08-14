class ServiceFormType {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final num feeAmount;
  final bool active;
  final String? createdAt;
  final String? updatedAt;

  const ServiceFormType({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.feeAmount,
    required this.active,
    this.createdAt,
    this.updatedAt,
  });
}
