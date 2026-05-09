import '../../domain/entities/application.dart';

class ApplicationModel extends Application {
  ApplicationModel({
    required super.id,
    required super.jobId,
    required super.seekerId,
    required super.employerId,
    required super.status,
    super.coverLetter,
    required super.createdAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'],
      jobId: json['job_id'],
      seekerId: json['seeker_id'],
      employerId: json['employer_id'],
      status: json['status'],
      coverLetter: json['cover_letter'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
