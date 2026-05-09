import '../../domain/entities/application.dart';
import '../../domain/repositories/application_repository.dart';
import '../datasources/application_remote_datasource.dart';

class ApplicationRepositoryImpl implements ApplicationRepository {
  final ApplicationRemoteDataSource remoteDataSource;

  ApplicationRepositoryImpl(this.remoteDataSource);

  @override
  Future<Application> applyForJob(
    int jobId,
    int employerId,
    String coverLetter,
  ) async {
    return await remoteDataSource.applyForJob(jobId, employerId, coverLetter);
  }

  @override
  Future<List<Application>> getApplications() async {
    return await remoteDataSource.getApplications();
  }

  @override
  Future<Application> updateStatus(int applicationId, String status) async {
    return await remoteDataSource.updateStatus(applicationId, status);
  }
}
