import '../../domain/entities/job.dart';

class JobModel extends Job {
  const JobModel({
    required super.id,
    required super.title,
    required super.description,
    required super.companyName,
    required super.location,
    required super.salary,
    required super.requirements,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      companyName: json['companyName'] ?? '',
      location: json['location'] ?? '',
      salary: (json['salary'] as num?)?.toDouble() ?? 0.0,
      requirements: json['requirements'] != null
          ? List<String>.from(json['requirements'])
          : [],
    );
  }
}