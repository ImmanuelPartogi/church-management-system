class Warta {
  final int id;
  final String title;
  final String? description;
  final String fileName;
  final int fileSize;
  final String mimeType;
  final String publishedAt;
  final bool isPublished;
  final int downloadCount;

  const Warta({
    required this.id,
    required this.title,
    this.description,
    required this.fileName,
    required this.fileSize,
    required this.mimeType,
    required this.publishedAt,
    required this.isPublished,
    required this.downloadCount,
  });
}
