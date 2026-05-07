import '../entities/application.dart';
import '../repositories/application_repository.dart';

class ApplyForJobUseCase {
  final ApplicationRepository repository;
  ApplyForJobUseCase(this.repository);

  Future<Application> call(
    int jobId,
    int employerId,
    String coverLetter,
  ) async {
    return await repository.applyForJob(jobId, employerId, coverLetter);
  }
}
