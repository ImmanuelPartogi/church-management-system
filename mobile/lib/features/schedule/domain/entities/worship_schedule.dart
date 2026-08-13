class WorshipSchedule {
  final int id;
  final String title;
  final String? description;
  final String day;
  final String startTime;
  final String? endTime;
  final String? location;
  final bool active;

  const WorshipSchedule({
    required this.id,
    required this.title,
    this.description,
    required this.day,
    required this.startTime,
    this.endTime,
    this.location,
    required this.active,
  });
}
