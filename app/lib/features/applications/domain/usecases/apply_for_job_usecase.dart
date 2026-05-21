import '../entities/application.dart';
import '../repositories/application_repository.dart';

class ApplyForJobUseCase {
  final ApplicationRepository repository;
  ApplyForJobUseCase(this.repository);

  Future<Application> call(
    String jobId,
    String employerId,
    String coverLetter,
  ) async {
    return await repository.applyForJob(jobId, employerId, coverLetter);
  }
}
