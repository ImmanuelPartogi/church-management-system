import 'package:flutter_test/flutter_test.dart';
import 'package:church_management_mobile/features/auth/data/models/user_model.dart';
import 'package:church_management_mobile/features/auth/domain/entities/user.dart';

void main() {
  group('UserModel & User entity', () {
    const userJson = {
      'id': 1,
      'name': 'Test User',
      'email': 'test@example.com',
      'roles': ['member', 'admin'],
    };

    test('should correctly deserialize from JSON', () {
      final userModel = UserModel.fromJson(userJson);

      expect(userModel.id, equals(1));
      expect(userModel.name, equals('Test User'));
      expect(userModel.email, equals('test@example.com'));
      expect(userModel.roles, containsAll(['member', 'admin']));
    });

    test('should convert UserModel to User entity correctly', () {
      final userModel = UserModel.fromJson(userJson);
      final User user = userModel.toEntity();

      expect(user.id, equals(1));
      expect(user.name, equals('Test User'));
      expect(user.email, equals('test@example.com'));
      expect(user.roles, containsAll(['member', 'admin']));
      expect(user.isAdmin, isTrue);
      expect(user.isMember, isTrue);
    });
  });
}
