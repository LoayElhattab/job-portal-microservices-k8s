import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/job.dart';

abstract class JobRepository {
  Future<Either<Failure, List<Job>>> getJobs();
  Future<Either<Failure, Job>> getJobDetails(String id);
}