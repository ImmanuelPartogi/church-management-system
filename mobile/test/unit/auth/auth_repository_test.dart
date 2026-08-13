import 'package:flutter_test/flutter_test.dart';
import 'package:church_management_mobile/features/auth/data/models/user_model.dart';
import 'package:church_management_mobile/features/auth/domain/entities/user.dart';

void main() {
  group('AuthRepository logic tests', () {
    test('UserModel mapped to entity correctly', () {
      const model = UserModel(
        id: 10,
        name: 'Pastor John',
        email: 'pastor@church.org',
        roles: ['admin', 'member'],
      );

      final user = model.toEntity();

      expect(user, isA<User>());
      expect(user.id, 10);
      expect(user.name, 'Pastor John');
      expect(user.email, 'pastor@church.org');
      expect(user.isAdmin, isTrue);
    });
  });
}
