class Announcement {
  final int id;
  final String title;
  final String content;
  final String? image;
  final String? publishedAt;
  final String status;

  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    this.image,
    this.publishedAt,
    required this.status,
  });
}
