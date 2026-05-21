import '../../domain/entities/application.dart';

class ApplicationModel extends Application {
  ApplicationModel({
    required super.id,
    super.jobId,
    required super.seekerId,
    super.employerId,
    required super.status,
    super.coverLetter,
    super.createdAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id']?.toString() ?? '',
      jobId: json['job_id']?.toString(),
      seekerId: json['seeker_id']?.toString() ?? '',
      employerId: json['employer_id']?.toString(),
      status: json['status'] ?? '',
      coverLetter: json['cover_letter'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}
