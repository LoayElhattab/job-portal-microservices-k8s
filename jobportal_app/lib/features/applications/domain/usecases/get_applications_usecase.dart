import '../entities/application.dart';
import '../repositories/application_repository.dart';

class GetApplicationsUseCase {
  final ApplicationRepository repository;
  GetApplicationsUseCase(this.repository);

  Future<List<Application>> call() async {
    return await repository.getApplications();
  }
}
