part of 'job_bloc.dart';

abstract class JobEvent {
  const JobEvent();
}

class GetJobsEvent extends JobEvent {}

class CreateJobEvent extends JobEvent {
  final String title;
  final String description;
  final String company;
  final String location;
  final String salary;

  const CreateJobEvent({
    required this.title,
    required this.description,
    required this.company,
    required this.location,
    required this.salary,
  });
}