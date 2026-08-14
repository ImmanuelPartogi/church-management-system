import 'package:flutter_test/flutter_test.dart';
import 'package:church_management_mobile/features/warta/data/models/warta_model.dart';

void main() {
  group('WartaModel Unit Tests', () {
    const jsonFull = {
      'id': 1,
      'title': 'Warta Jemaat 14 Agustus 2026',
      'description': 'Informasi ibadah dan kegiatan jemaat.',
      'file_name': 'warta_2026_08_14.pdf',
      'file_size': 1048576,
      'mime_type': 'application/pdf',
      'download_count': 5,
      'published_at': '2026-08-14 10:00:00',
      'is_published': true,
      'created_at': '2026-08-14 09:00:00',
      'updated_at': '2026-08-14 09:30:00',
    };

    const jsonNullable = {
      'id': 2,
      'title': 'Warta Jemaat Tanpa Deskripsi',
      'description': null,
      'file_name': 'warta_no_desc.pdf',
      'file_size': 512000,
      'mime_type': 'application/pdf',
      'download_count': 0,
      'published_at': '2026-08-14 12:00:00',
      'is_published': true,
      'created_at': '2026-08-14 12:00:00',
      'updated_at': '2026-08-14 12:00:00',
    };

    test('should parse full JSON and convert to entity correctly', () {
      final model = WartaModel.fromJson(jsonFull);

      expect(model.id, 1);
      expect(model.title, 'Warta Jemaat 14 Agustus 2026');
      expect(model.description, 'Informasi ibadah dan kegiatan jemaat.');
      expect(model.fileName, 'warta_2026_08_14.pdf');
      expect(model.fileSize, 1048576);
      expect(model.mimeType, 'application/pdf');
      expect(model.downloadCount, 5);
      expect(model.publishedAt, '2026-08-14 10:00:00');
      expect(model.isPublished, true);

      final entity = model.toEntity();
      expect(entity.id, 1);
      expect(entity.title, 'Warta Jemaat 14 Agustus 2026');
      expect(entity.description, 'Informasi ibadah dan kegiatan jemaat.');
      expect(entity.fileName, 'warta_2026_08_14.pdf');
      expect(entity.fileSize, 1048576);
      expect(entity.mimeType, 'application/pdf');
      expect(entity.downloadCount, 5);
      expect(entity.publishedAt, '2026-08-14 10:00:00');
      expect(entity.isPublished, true);
    });

    test('should parse JSON with nullable description correctly', () {
      final model = WartaModel.fromJson(jsonNullable);

      expect(model.id, 2);
      expect(model.title, 'Warta Jemaat Tanpa Deskripsi');
      expect(model.description, isNull);
      expect(model.downloadCount, 0);

      final entity = model.toEntity();
      expect(entity.id, 2);
      expect(entity.title, 'Warta Jemaat Tanpa Deskripsi');
      expect(entity.description, isNull);
      expect(entity.downloadCount, 0);
    });
  });
}
