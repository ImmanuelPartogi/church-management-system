class DailyVerse {
  final int id;
  final String verseReference;
  final String content;
  final String? date;

  const DailyVerse({
    required this.id,
    required this.verseReference,
    required this.content,
    this.date,
  });
}
