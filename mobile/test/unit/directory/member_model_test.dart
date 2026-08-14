import 'package:church_management_mobile/features/directory/data/models/member_detail_model.dart';
import 'package:church_management_mobile/features/directory/data/models/member_directory_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MemberDirectoryModel Tests', () {
    test('should parse MemberDirectoryModel from JSON correctly', () {
      final json = {
        'id': 1,
        'membership_number': 'MB-001',
        'full_name': 'Stiven Hutapea',
        'gender': 'Male',
        'status': 'active',
        'masked_phone': '0812****7890',
        'has_app_account': true,
      };

      final model = MemberDirectoryModel.fromJson(json);

      expect(model.id, 1);
      expect(model.membershipNumber, 'MB-001');
      expect(model.fullName, 'Stiven Hutapea');
      expect(model.gender, 'Male');
      expect(model.status, 'active');
      expect(model.maskedPhone, '0812****7890');
      expect(model.hasAppAccount, true);

      final entity = model.toEntity();
      expect(entity.id, 1);
      expect(entity.fullName, 'Stiven Hutapea');
      expect(entity.maskedPhone, '0812****7890');
    });
  });

  group('MemberDetailModel Tests', () {
    test('should parse MemberDetailModel from JSON correctly', () {
      final json = {
        'id': 1,
        'membership_number': 'MB-001',
        'full_name': 'Stiven Hutapea',
        'gender': 'Male',
        'birth_date': '1990-05-15',
        'phone': '081234567890',
        'email': 'stiven@example.com',
        'address': 'Jl. Balige No. 45',
        'baptism_date': '2005-04-10',
        'status': 'active',
        'has_app_account': true,
      };

      final model = MemberDetailModel.fromJson(json);

      expect(model.id, 1);
      expect(model.fullName, 'Stiven Hutapea');
      expect(model.phone, '081234567890');
      expect(model.email, 'stiven@example.com');
      expect(model.address, 'Jl. Balige No. 45');

      final entity = model.toEntity();
      expect(entity.id, 1);
      expect(entity.address, 'Jl. Balige No. 45');
    });
  });
}
