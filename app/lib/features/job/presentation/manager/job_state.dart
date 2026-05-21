part of 'job_bloc.dart';

abstract class JobState {
  const JobState();
}

class JobInitial extends JobState {}
class JobLoading extends JobState {}
class JobLoaded extends JobState {
  final List<Job> jobs;
  const JobLoaded({required this.jobs});
}
class JobError extends JobState {
  final String message;
  const JobError({required this.message});
}

class JobCreated extends JobState {
  final Job job;
  const JobCreated({required this.job});
}