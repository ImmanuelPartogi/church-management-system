import 'package:flutter_test/flutter_test.dart';
import 'package:church_management_mobile/features/schedule/data/models/worship_schedule_model.dart';

void main() {
  group('WorshipScheduleModel', () {
    const json = {
      'id': 1,
      'title': 'Ibadah Raya Minggu I',
      'description': 'Ibadah umum sesi pagi',
      'day': 'Minggu',
      'start_time': '08:00',
      'end_time': '10:00',
      'location': 'Gereja Utama',
      'active': true,
    };

    test('should parse from JSON and convert to entity correctly', () {
      final model = WorshipScheduleModel.fromJson(json);

      expect(model.id, 1);
      expect(model.title, 'Ibadah Raya Minggu I');
      expect(model.day, 'Minggu');
      expect(model.startTime, '08:00');
      expect(model.endTime, '10:00');
      expect(model.active, isTrue);

      final entity = model.toEntity();
      expect(entity.title, 'Ibadah Raya Minggu I');
      expect(entity.day, 'Minggu');
    });
  });
}
