import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/apply_for_job_usecase.dart';
import '../../domain/usecases/get_applications_usecase.dart';
import '../../domain/usecases/update_application_status_usecase.dart';
import 'application_event.dart';
import 'application_state.dart';

class ApplicationBloc extends Bloc<ApplicationEvent, ApplicationState> {
  final GetApplicationsUseCase getApplicationsUseCase;
  final ApplyForJobUseCase applyForJobUseCase;
  final UpdateApplicationStatusUseCase updateStatusUseCase;

  ApplicationBloc({
    required this.getApplicationsUseCase,
    required this.applyForJobUseCase,
    required this.updateStatusUseCase,
  }) : super(ApplicationInitial()) {
    on<LoadApplications>((event, emit) async {
      emit(ApplicationLoading());
      try {
        final applications = await getApplicationsUseCase();
        emit(ApplicationsLoaded(applications));
      } catch (e) {
        emit(ApplicationError('Failed to load applications.'));
      }
    });

    on<ApplyForJobEvent>((event, emit) async {
      emit(ApplicationLoading());
      try {
        await applyForJobUseCase(
          event.jobId,
          event.employerId,
          event.coverLetter,
        );
        emit(ApplicationActionSuccess('Application submitted successfully!'));
        add(LoadApplications());
      } catch (e) {
        if (e.toString().contains('DUPLICATE_ENTRY')) {
          emit(ApplicationError('You have already applied for this job.'));
        } else {
          emit(ApplicationError('Failed to submit application.'));
        }
      }
    });

    on<UpdateStatusEvent>((event, emit) async {
      emit(ApplicationLoading());
      try {
        await updateStatusUseCase(event.applicationId, event.newStatus);
        emit(ApplicationActionSuccess('Status updated to ${event.newStatus}!'));
        add(LoadApplications());
      } catch (e) {
        emit(ApplicationError('Failed to update status.'));
      }
    });
  }
}
