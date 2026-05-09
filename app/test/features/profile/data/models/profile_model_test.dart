import 'package:flutter_test/flutter_test.dart';
import 'package:jobportal_app/features/profile/data/models/profile_model.dart';
import 'package:jobportal_app/features/profile/domain/entities/profile.dart';

void main() {
  final tProfileModel = ProfileModel(
    id: '1',
    name: 'John Doe',
    email: 'john@example.com',
    role: 'seeker',
    bio: 'Software Developer',
    skills: const ['Flutter', 'Dart'],
  );

  test('should be a subclass of Profile entity', () async {
    expect(tProfileModel, isA<Profile>());
  });

  group('fromJson', () {
    test('should return a valid model when the JSON is correct', () async {
      // arrange
      final Map<String, dynamic> jsonMap = {
        'id': '1',
        'name': 'John Doe',
        'email': 'john@example.com',
        'role': 'seeker',
        'bio': 'Software Developer',
        'skills': ['Flutter', 'Dart'],
      };
      // act
      final result = ProfileModel.fromJson(jsonMap);
      // assert
      expect(result.id, tProfileModel.id);
      expect(result.name, tProfileModel.name);
      expect(result.bio, tProfileModel.bio);
    });

    test('should handle missing fields with defaults', () {
      final result = ProfileModel.fromJson({});
      expect(result.id, '');
      expect(result.bio, 'No bio available');
      expect(result.skills, []);
    });
  });
}
