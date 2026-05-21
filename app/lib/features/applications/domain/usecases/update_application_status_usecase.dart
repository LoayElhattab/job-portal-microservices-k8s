import '../entities/application.dart';
import '../repositories/application_repository.dart';

class UpdateApplicationStatusUseCase {
  final ApplicationRepository repository;
  UpdateApplicationStatusUseCase(this.repository);

  Future<Application> call(String applicationId, String status) async {
    return await repository.updateStatus(applicationId, status);
  }
}
