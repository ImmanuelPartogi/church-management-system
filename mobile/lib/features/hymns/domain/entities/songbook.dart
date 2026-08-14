class Songbook {
  final int id;
  final String name;
  final String code;
  final String? description;
  final int? songCount;

  const Songbook({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.songCount,
  });
}
