import 'package:dio/dio.dart';
import '../models/job_model.dart';

abstract class JobRemoteDataSource {
  Future<List<JobModel>> getJobs();
  Future<JobModel> createJob(String title, String description, String company, String location, String salary);
}

class JobRemoteDataSourceImpl implements JobRemoteDataSource {
  final Dio dio;

  JobRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<JobModel>> getJobs() async {
    final response = await dio.get('/jobs');

    if (response.statusCode == 200) {
      final List data = response.data['data'];
      return data.map((json) => JobModel.fromJson(json)).toList();
    } else {
      throw Exception();
    }
  }

  @override
  Future<JobModel> createJob(
    String title,
    String description,
    String company,
    String location,
    String salary,
  ) async {
    final response = await dio.post(
      '/jobs',
      data: {
        'title': title,
        'description': description,
        'company': company,
        'location': location,
        'salary': salary,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return JobModel.fromJson(response.data['data']['job']);
    } else {
      throw Exception('Failed to create job');
    }
  }
}