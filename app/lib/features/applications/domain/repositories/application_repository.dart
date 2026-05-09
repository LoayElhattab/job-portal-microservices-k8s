import '../entities/application.dart';

abstract class ApplicationRepository {
  Future<Application> applyForJob(
    int jobId,
    int employerId,
    String coverLetter,
  );
  Future<List<Application>> getApplications();
  Future<Application> updateStatus(int applicationId, String status);
}
