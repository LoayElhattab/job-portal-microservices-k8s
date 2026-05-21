import '../entities/application.dart';

abstract class ApplicationRepository {
  Future<Application> applyForJob(
    String jobId,
    String employerId,
    String coverLetter,
  );
  Future<List<Application>> getApplications();
  Future<Application> updateStatus(String applicationId, String status);
}
