import 'package:church_management_mobile/features/prayer_requests/data/models/prayer_request_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PrayerRequestModel Tests', () {
    test('should parse PrayerRequestModel from JSON correctly', () {
      final json = {
        'id': 1,
        'user_id': 2,
        'member_id': 5,
        'title': 'Doa Kesembuhan',
        'content': 'Mohon doa untuk kesembuhan dari sakit flu.',
        'category': 'Kesehatan',
        'is_private': true,
        'status': 'submitted',
        'follow_up_notes': null,
        'followed_up_at': null,
        'created_at': '2026-08-14T10:00:00.000000Z',
        'updated_at': '2026-08-14T10:00:00.000000Z',
      };

      final model = PrayerRequestModel.fromJson(json);

      expect(model.id, 1);
      expect(model.userId, 2);
      expect(model.title, 'Doa Kesembuhan');
      expect(model.content, 'Mohon doa untuk kesembuhan dari sakit flu.');
      expect(model.category, 'Kesehatan');
      expect(model.isPrivate, true);
      expect(model.status, 'submitted');

      final entity = model.toEntity();
      expect(entity.title, 'Doa Kesembuhan');
      expect(entity.isPrivate, true);
    });

    test('should parse PrayerRequestModel with pastoral follow up notes', () {
      final json = {
        'id': 2,
        'user_id': 2,
        'member_id': 5,
        'title': 'Doa Ucapan Syukur',
        'content': 'Mengucapkan syukur atas ulang tahun.',
        'category': 'Ucapan Syukur',
        'is_private': false,
        'status': 'followed_up',
        'follow_up_notes': 'Telah didoakan oleh Pendeta.',
        'followed_up_at': '2026-08-14T12:00:00.000000Z',
        'created_at': '2026-08-14T10:00:00.000000Z',
        'updated_at': '2026-08-14T12:00:00.000000Z',
      };

      final model = PrayerRequestModel.fromJson(json);

      expect(model.status, 'followed_up');
      expect(model.followUpNotes, 'Telah didoakan oleh Pendeta.');
      expect(model.isPrivate, false);

      final entity = model.toEntity();
      expect(entity.followUpNotes, 'Telah didoakan oleh Pendeta.');
    });
  });
}
