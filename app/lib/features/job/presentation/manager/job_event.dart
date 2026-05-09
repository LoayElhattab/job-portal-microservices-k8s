part of 'job_bloc.dart';

abstract class JobEvent {
  const JobEvent();
}

class GetJobsEvent extends JobEvent {}