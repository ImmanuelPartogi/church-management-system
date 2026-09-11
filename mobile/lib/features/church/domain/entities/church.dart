class Church {
  final int id;
  final String uuid;
  final String name;
  final String slug;
  final String? timezone;
  final String? address;
  final String? phone;
  final String? logoUrl;
  final String? themePrimaryColor;
  final String? themeSecondaryColor;
  final int? themeVersion;

  const Church({
    required this.id,
    required this.uuid,
    required this.name,
    required this.slug,
    this.timezone,
    this.address,
    this.phone,
    this.logoUrl,
    this.themePrimaryColor,
    this.themeSecondaryColor,
    this.themeVersion,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Church &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          slug == other.slug;

  @override
  int get hashCode => id.hashCode ^ slug.hashCode;

  @override
  String toString() => 'Church(id: $id, name: $name, slug: $slug)';
}
