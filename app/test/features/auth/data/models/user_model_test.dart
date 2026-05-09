import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobportal_app/features/auth/data/models/user_model.dart';
import 'package:jobportal_app/features/auth/domain/entities/user.dart';

void main() {
  final tUserModel = UserModel(
    id: 1,
    email: 'test@example.com',
    role: 'seeker',
  );

  test('should be a subclass of User entity', () async {
    expect(tUserModel, isA<User>());
  });

  group('fromJson', () {
    test('should return a valid model when the JSON is correct', () async {
      // arrange
      final Map<String, dynamic> jsonMap = {
        'id': 1,
        'email': 'test@example.com',
        'role': 'seeker',
      };
      // act
      final result = UserModel.fromJson(jsonMap);
      // assert
      expect(result.id, tUserModel.id);
      expect(result.email, tUserModel.email);
      expect(result.role, tUserModel.role);
    });
  });
}
