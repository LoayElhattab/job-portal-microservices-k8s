abstract class ApplicationEvent {}

class LoadApplications extends ApplicationEvent {}

class ApplyForJobEvent extends ApplicationEvent {
  final String jobId;
  final String employerId;
  final String coverLetter;

  ApplyForJobEvent({
    required this.jobId,
    required this.employerId,
    required this.coverLetter,
  });
}

class UpdateStatusEvent extends ApplicationEvent {
  final String applicationId;
  final String newStatus;

  UpdateStatusEvent({required this.applicationId, required this.newStatus});
}
