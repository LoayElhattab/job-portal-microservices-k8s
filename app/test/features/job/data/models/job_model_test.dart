import 'package:flutter_test/flutter_test.dart';
import 'package:jobportal_app/features/job/data/models/job_model.dart';
import 'package:jobportal_app/features/job/domain/entities/job.dart';

void main() {
  final tJobModel = JobModel(
    id: '1',
    employerId: '10',
    title: 'Software Engineer',
    description: 'A great role',
    companyName: 'Tech Corp',
    location: 'Remote',
    salary: '100000',
    requirements: const ['Dart', 'Flutter'],
  );

  test('should be a subclass of Job entity', () async {
    expect(tJobModel, isA<Job>());
  });

  group('fromJson', () {
    test('should return a valid model when the JSON is correct', () async {
      // arrange
      final Map<String, dynamic> jsonMap = {
        'id': 1,
        'employer_id': '10',
        'title': 'Software Engineer',
        'description': 'A great role',
        'companyName': 'Tech Corp',
        'location': 'Remote',
        'salary': 100000,
        'requirements': ['Dart', 'Flutter'],
      };
      // act
      final result = JobModel.fromJson(jsonMap);
      // assert
      expect(result.id, '1'); // converted to string in fromJson
      expect(result.title, tJobModel.title);
      expect(result.salary, tJobModel.salary);
    });

    test('should handle missing fields with defaults', () {
      final result = JobModel.fromJson({});
      expect(result.id, '');
      expect(result.title, '');
      expect(result.salary, '');
      expect(result.requirements, []);
    });
  });
}
