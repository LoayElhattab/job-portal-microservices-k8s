import '../../domain/entities/job.dart';

class JobModel extends Job {
  const JobModel({
    required super.id,
    required super.employerId,
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
      employerId: json['employer_id']?.toString() ?? json['employerId']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      companyName: json['companyName'] ?? json['company'] ?? '',
      location: json['location'] ?? '',
      salary: json['salary']?.toString() ?? '',
      requirements: json['requirements'] != null
          ? List<String>.from(json['requirements'])
          : [],
    );
  }
}