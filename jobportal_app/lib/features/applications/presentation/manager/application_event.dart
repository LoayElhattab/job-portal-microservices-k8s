abstract class ApplicationEvent {}

class LoadApplications extends ApplicationEvent {}

class ApplyForJobEvent extends ApplicationEvent {
  final int jobId;
  final int employerId;
  final String coverLetter;

  ApplyForJobEvent({
    required this.jobId,
    required this.employerId,
    required this.coverLetter,
  });
}

class UpdateStatusEvent extends ApplicationEvent {
  final int applicationId;
  final String newStatus;

  UpdateStatusEvent({required this.applicationId, required this.newStatus});
}
