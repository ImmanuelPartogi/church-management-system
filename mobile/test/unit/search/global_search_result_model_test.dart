import 'package:flutter_test/flutter_test.dart';
import 'package:church_management_mobile/features/search/data/models/global_search_result_model.dart';

void main() {
  group('GlobalSearchResultModel Tests', () {
    test('should parse GlobalSearchResultModel from JSON correctly', () {
      final json = {
        'success': true,
        'message': 'Global search results retrieved successfully.',
        'data': {
          'query': 'kasih',
          'results': {
            'members': [
              {
                'id': 1,
                'membership_number': 'MB-001',
                'full_name': 'Budi Kasih',
                'gender': 'male',
                'status': 'active',
                'masked_phone': '0812****7890',
                'has_app_account': true,
              }
            ],
            'servants': [
              {
                'id': 1,
                'name': 'St. Kasih',
                'role': 'sintua',
                'role_label': 'Sintua / Penatua',
                'masked_phone': '0813****1234',
                'active': true,
              }
            ],
            'sermons': [
              {
                'id': 10,
                'title': 'Khotbah tentang Kasih',
                'preacher_name': 'Pdt. Alex',
                'sermon_date': '2026-08-01',
                'download_count': 5,
                'is_published': true,
              }
            ],
            'hymns': <Map<String, dynamic>>[],
            'wartas': <Map<String, dynamic>>[],
            'announcements': <Map<String, dynamic>>[],
          },
          'meta': {
            'total': 3,
            'counts': {
              'members': 1,
              'servants': 1,
              'sermons': 1,
              'hymns': 0,
              'wartas': 0,
              'announcements': 0,
            },
          },
        },
      };

      final model = GlobalSearchResultModel.fromJson(json);

      expect(model.query, 'kasih');
      expect(model.members.length, 1);
      expect(model.members.first.fullName, 'Budi Kasih');
      expect(model.servants.length, 1);
      expect(model.servants.first.name, 'St. Kasih');
      expect(model.sermons.length, 1);
      expect(model.sermons.first.title, 'Khotbah tentang Kasih');
      expect(model.totalCount, 3);

      final entity = model.toEntity();
      expect(entity.query, 'kasih');
      expect(entity.members.length, 1);
      expect(entity.totalCount, 3);
      expect(entity.isEmpty, false);
    });
  });
}
