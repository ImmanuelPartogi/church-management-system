import 'package:church_management_mobile/features/community/data/models/church_servant_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChurchServantModel Tests', () {
    test('should parse ChurchServantModel from JSON correctly', () {
      final json = {
        'id': 1,
        'name': 'Pdt. Stiven Hutapea',
        'role': 'pdt_resort',
        'role_label': 'Pendeta Resort',
        'masked_phone': '0812****7890',
        'email': 'stiven@example.com',
        'description': 'Pendeta Resort Medan',
        'active': true,
        'resort_name': 'HKBP Resort Medan',
        'sector_name': 'Sektor I',
      };

      final model = ChurchServantModel.fromJson(json);

      expect(model.id, 1);
      expect(model.name, 'Pdt. Stiven Hutapea');
      expect(model.role, 'pdt_resort');
      expect(model.roleLabel, 'Pendeta Resort');
      expect(model.maskedPhone, '0812****7890');
      expect(model.resortName, 'HKBP Resort Medan');

      final entity = model.toEntity();
      expect(entity.id, 1);
      expect(entity.roleLabel, 'Pendeta Resort');
    });
  });
}
