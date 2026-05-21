import 'package:equatable/equatable.dart';

class Job extends Equatable {
  final String id;
  final String employerId;
  final String title;
  final String description;
  final String companyName;
  final String location;
  final String salary;
  final List<String> requirements;

  const Job({
    required this.id,
    required this.employerId,
    required this.title,
    required this.description,
    required this.companyName,
    required this.location,
    required this.salary,
    required this.requirements,
  });

  @override
  List<Object?> get props => [id, employerId, title, description, companyName, location, salary, requirements];
}