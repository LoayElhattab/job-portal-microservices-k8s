import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/job.dart';

abstract class JobRepository {
  Future<Either<Failure, List<Job>>> getJobs();
  Future<Either<Failure, Job>> getJobDetails(String id);
  Future<Either<Failure, Job>> createJob(
    String title,
    String description,
    String company,
    String location,
    String salary,
  );
}