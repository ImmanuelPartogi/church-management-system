class PrayerRequest {
  final int id;
  final int userId;
  final int? memberId;
  final String title;
  final String content;
  final String? category;
  final bool isPrivate;
  final String status;
  final String? followUpNotes;
  final String? followedUpAt;
  final String createdAt;
  final String updatedAt;

  const PrayerRequest({
    required this.id,
    required this.userId,
    this.memberId,
    required this.title,
    required this.content,
    this.category,
    required this.isPrivate,
    required this.status,
    this.followUpNotes,
    this.followedUpAt,
    required this.createdAt,
    required this.updatedAt,
  });
}
