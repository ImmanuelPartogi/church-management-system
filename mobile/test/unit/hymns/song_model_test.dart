import 'package:church_management_mobile/features/hymns/data/models/song_model.dart';
import 'package:church_management_mobile/features/hymns/data/models/songbook_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SongbookModel Tests', () {
    test('should parse SongbookModel from JSON correctly', () {
      final json = {
        'id': 1,
        'name': 'Buku Ende',
        'code': 'BE',
        'description': 'Buku Ende HKBP',
        'song_count': 294,
      };

      final model = SongbookModel.fromJson(json);

      expect(model.id, 1);
      expect(model.name, 'Buku Ende');
      expect(model.code, 'BE');
      expect(model.description, 'Buku Ende HKBP');
      expect(model.songCount, 294);

      final entity = model.toEntity();
      expect(entity.id, 1);
      expect(entity.code, 'BE');
      expect(entity.songCount, 294);
    });
  });

  group('SongModel Tests', () {
    test('should parse SongModel from JSON and convert to entity correctly',
        () {
      final json = {
        'id': 10,
        'songbook_id': 1,
        'songbook_name': 'Buku Ende',
        'songbook_code': 'BE',
        'number': 1,
        'title': 'O Debata Trinunggal',
        'lyrics': 'Bait 1: O Debata Trinunggal i.\nBait 2: Pasupasu hami.',
        'created_at': '2026-08-12T00:00:00.000000Z',
        'updated_at': '2026-08-12T00:00:00.000000Z',
      };

      final model = SongModel.fromJson(json);

      expect(model.id, 10);
      expect(model.songbookId, 1);
      expect(model.songbookName, 'Buku Ende');
      expect(model.songbookCode, 'BE');
      expect(model.number, 1);
      expect(model.title, 'O Debata Trinunggal');
      expect(model.lyrics, contains('Debata Trinunggal'));

      final entity = model.toEntity();
      expect(entity.id, 10);
      expect(entity.songbookCode, 'BE');
      expect(entity.number, 1);
      expect(entity.title, 'O Debata Trinunggal');
    });
  });
}
