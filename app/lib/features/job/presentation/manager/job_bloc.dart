import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/job.dart';
import '../../domain/usecases/get_jobs_usecase.dart';

part 'job_event.dart';
part 'job_state.dart';

class JobBloc extends Bloc<JobEvent, JobState> {
  final GetJobsUseCase getJobsUseCase;

  JobBloc({required this.getJobsUseCase}) : super(JobInitial()) {
    on<GetJobsEvent>((event, emit) async {
      emit(JobLoading());

      final result = await getJobsUseCase();

      result.fold(
            (failure) => emit(const JobError(message: 'Server Failure')),
            (jobs) => emit(JobLoaded(jobs: jobs)),
      );
    });
  }
}