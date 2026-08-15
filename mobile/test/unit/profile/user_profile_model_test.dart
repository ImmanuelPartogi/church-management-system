import 'package:flutter_test/flutter_test.dart';
import 'package:church_management_mobile/features/profile/data/models/user_profile_model.dart';

void main() {
  group('UserProfileModel Tests', () {
    test('should parse UserProfileModel from JSON with linked member correctly',
        () {
      final json = {
        'success': true,
        'message': 'Profile retrieved successfully.',
        'data': {
          'id': 1,
          'name': 'Budi Jemaat',
          'email': 'budi@example.com',
          'phone': '081234567890',
          'address': 'Jl. Gereja No. 1',
          'roles': ['member'],
          'member': {
            'id': 10,
            'membership_number': 'MB-001',
            'full_name': 'Budi Jemaat',
            'gender': 'male',
            'status': 'active',
            'masked_phone': '0812****7890',
            'has_app_account': true,
          },
        },
      };

      final model = UserProfileModel.fromJson(json);

      expect(model.id, 1);
      expect(model.name, 'Budi Jemaat');
      expect(model.email, 'budi@example.com');
      expect(model.phone, '081234567890');
      expect(model.address, 'Jl. Gereja No. 1');
      expect(model.roles, ['member']);
      expect(model.member, isNotNull);
      expect(model.member!.membershipNumber, 'MB-001');

      final entity = model.toEntity();
      expect(entity.id, 1);
      expect(entity.hasLinkedMember, true);
      expect(entity.member!.fullName, 'Budi Jemaat');
    });

    test('should parse UserProfileModel from JSON with null member correctly',
        () {
      final json = {
        'success': true,
        'message': 'Profile retrieved successfully.',
        'data': {
          'id': 2,
          'name': 'Guest User',
          'email': 'guest@example.com',
          'phone': null,
          'address': null,
          'roles': <String>[],
          'member': null,
        },
      };

      final model = UserProfileModel.fromJson(json);

      expect(model.id, 2);
      expect(model.name, 'Guest User');
      expect(model.member, isNull);

      final entity = model.toEntity();
      expect(entity.id, 2);
      expect(entity.hasLinkedMember, false);
    });
  });
}
