import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/job.dart';
import '../../domain/repositories/job_repository.dart';
import '../datasources/job_remote_datasource.dart';

class JobRepositoryImpl implements JobRepository {
  final JobRemoteDataSource remoteDataSource;

  JobRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Job>>> getJobs() async {
    try {
      final remoteJobs = await remoteDataSource.getJobs();
      return Right(remoteJobs);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Job>> getJobDetails(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Job>> createJob(
    String title,
    String description,
    String company,
    String location,
    String salary,
  ) async {
    try {
      final remoteJob = await remoteDataSource.createJob(
        title,
        description,
        company,
        location,
        salary,
      );
      return Right(remoteJob);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
