import 'package:church_management_mobile/features/media/data/models/sermon_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SermonModel Tests', () {
    test('should parse SermonModel from JSON correctly', () {
      final json = {
        'id': 1,
        'title': 'Kasih Allah yang Sempurna',
        'description': 'Ringkasan khotbah Minggu Pemuda',
        'preacher_name': 'Pdt. Stiven Hutapea',
        'file_name': 'khotbah_minggu.pdf',
        'file_size': 1048576,
        'mime_type': 'application/pdf',
        'download_count': 12,
        'published_at': '2026-08-10T10:00:00Z',
        'is_published': true,
      };

      final model = SermonModel.fromJson(json);

      expect(model.id, 1);
      expect(model.title, 'Kasih Allah yang Sempurna');
      expect(model.preacherName, 'Pdt. Stiven Hutapea');
      expect(model.downloadCount, 12);

      final entity = model.toEntity();
      expect(entity.id, 1);
      expect(entity.preacherName, 'Pdt. Stiven Hutapea');
    });
  });
}
