import 'package:flutter_test/flutter_test.dart';
import 'package:church_management_mobile/features/announcement/data/models/announcement_model.dart';

void main() {
  group('AnnouncementModel', () {
    const json = {
      'id': 1,
      'title': 'Pengumuman Ibadah Minggu',
      'content': 'Ibadah Minggu dilaksanakan pukul 09:00 WIB.',
      'image': null,
      'published_at': '2026-08-10 10:00:00',
      'status': 'published',
    };

    test('should parse from JSON and convert to entity correctly', () {
      final model = AnnouncementModel.fromJson(json);

      expect(model.id, 1);
      expect(model.title, 'Pengumuman Ibadah Minggu');
      expect(model.content, contains('09:00 WIB'));
      expect(model.status, 'published');

      final entity = model.toEntity();
      expect(entity.title, 'Pengumuman Ibadah Minggu');
      expect(entity.status, 'published');
    });
  });
}
