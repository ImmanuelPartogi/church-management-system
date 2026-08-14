class Sermon {
  final int id;
  final String title;
  final String? description;
  final String preacherName;
  final String? fileName;
  final int? fileSize;
  final String? mimeType;
  final int downloadCount;
  final String? publishedAt;
  final bool isPublished;

  const Sermon({
    required this.id,
    required this.title,
    this.description,
    required this.preacherName,
    this.fileName,
    this.fileSize,
    this.mimeType,
    required this.downloadCount,
    this.publishedAt,
    required this.isPublished,
  });
}
