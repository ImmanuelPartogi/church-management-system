class Song {
  final int id;
  final int songbookId;
  final String? songbookName;
  final String? songbookCode;
  final int number;
  final String title;
  final String lyrics;
  final String? createdAt;
  final String? updatedAt;

  const Song({
    required this.id,
    required this.songbookId,
    this.songbookName,
    this.songbookCode,
    required this.number,
    required this.title,
    required this.lyrics,
    this.createdAt,
    this.updatedAt,
  });
}
