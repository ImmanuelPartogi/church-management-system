import 'package:flutter_test/flutter_test.dart';
import 'package:church_management_mobile/features/home/data/models/daily_verse_model.dart';

void main() {
  group('DailyVerseModel', () {
    const json = {
      'id': 1,
      'verse_reference': 'Yohanes 3:16',
      'content': 'Karena begitu besar kasih Allah akan dunia ini...',
      'date': '2026-08-13',
    };

    test('should parse from JSON and convert to entity correctly', () {
      final model = DailyVerseModel.fromJson(json);

      expect(model.id, 1);
      expect(model.verseReference, 'Yohanes 3:16');
      expect(model.content, contains('kasih Allah'));
      expect(model.date, '2026-08-13');

      final entity = model.toEntity();
      expect(entity.verseReference, 'Yohanes 3:16');
      expect(entity.content, contains('kasih Allah'));
    });
  });
}
