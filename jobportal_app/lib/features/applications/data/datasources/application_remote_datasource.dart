import '../../../../core/network/api_client.dart';
import '../models/application_model.dart';

class ApplicationRemoteDataSource {
  final ApiClient apiClient;

  ApplicationRemoteDataSource(this.apiClient);

  Future<ApplicationModel> applyForJob(
    int jobId,
    int employerId,
    String coverLetter,
  ) async {
    final response = await apiClient.dio.post(
      '/applications',
      data: {
        'jobId': jobId,
        'employerId': employerId,
        'coverLetter': coverLetter,
      },
    );
    return ApplicationModel.fromJson(response.data['data']);
  }

  Future<List<ApplicationModel>> getApplications() async {
    final response = await apiClient.dio.get('/applications');
    final List<dynamic> data = response.data['data'];
    return data.map((json) => ApplicationModel.fromJson(json)).toList();
  }

  Future<ApplicationModel> updateStatus(
    int applicationId,
    String status,
  ) async {
    final response = await apiClient.dio.patch(
      '/applications/$applicationId/status',
      data: {'status': status},
    );
    return ApplicationModel.fromJson(response.data['data']);
  }
}
