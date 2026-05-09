import 'package:dio/dio.dart';
import '../models/job_model.dart';

abstract class JobRemoteDataSource {
  Future<List<JobModel>> getJobs();
}

class JobRemoteDataSourceImpl implements JobRemoteDataSource {
  final Dio dio;

  JobRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<JobModel>> getJobs() async {
    final response = await dio.get('/api/v1/jobs');

    if (response.statusCode == 200) {
      final List data = response.data['data'];
      return data.map((json) => JobModel.fromJson(json)).toList();
    } else {
      throw Exception();
    }
  }
}