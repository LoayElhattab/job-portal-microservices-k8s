import 'package:flutter_test/flutter_test.dart';
import 'package:jobportal_app/features/applications/data/models/application_model.dart';
import 'package:jobportal_app/features/applications/domain/entities/application.dart';

void main() {
  final tApplicationModel = ApplicationModel(
    id: 1,
    jobId: 1,
    seekerId: 1,
    employerId: 1,
    status: 'pending',
    coverLetter: 'Hello',
    createdAt: DateTime.parse('2026-05-09T00:00:00.000Z'),
  );

  test('should be a subclass of Application entity', () async {
    expect(tApplicationModel, isA<Application>());
  });

  group('fromJson', () {
    test('should return a valid model when the JSON is correct', () async {
      // arrange
      final Map<String, dynamic> jsonMap = {
        'id': 1,
        'job_id': 1,
        'seeker_id': 1,
        'employer_id': 1,
        'status': 'pending',
        'cover_letter': 'Hello',
        'created_at': '2026-05-09T00:00:00.000Z',
      };
      // act
      final result = ApplicationModel.fromJson(jsonMap);
      // assert
      expect(result.id, tApplicationModel.id);
      expect(result.status, tApplicationModel.status);
      expect(result.createdAt, tApplicationModel.createdAt);
    });
  });
}
