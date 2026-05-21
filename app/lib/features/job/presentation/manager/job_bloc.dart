import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/job.dart';
import '../../domain/usecases/get_jobs_usecase.dart';
import '../../domain/usecases/create_job_usecase.dart';

part 'job_event.dart';
part 'job_state.dart';

class JobBloc extends Bloc<JobEvent, JobState> {
  final GetJobsUseCase getJobsUseCase;
  final CreateJobUseCase createJobUseCase;

  JobBloc({
    required this.getJobsUseCase,
    required this.createJobUseCase,
  }) : super(JobInitial()) {
    on<GetJobsEvent>((event, emit) async {
      emit(JobLoading());

      final result = await getJobsUseCase();

      result.fold(
        (failure) => emit(const JobError(message: 'Server Failure')),
        (jobs) => emit(JobLoaded(jobs: jobs)),
      );
    });

    on<CreateJobEvent>((event, emit) async {
      emit(JobLoading());

      final result = await createJobUseCase(
        event.title,
        event.description,
        event.company,
        event.location,
        event.salary,
      );

      result.fold(
        (failure) => emit(const JobError(message: 'Failed to create job')),
        (job) => emit(JobCreated(job: job)),
      );
    });
  }
}