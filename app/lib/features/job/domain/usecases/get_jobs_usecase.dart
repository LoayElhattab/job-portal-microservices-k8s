import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/job.dart';
import '../repositories/job_repository.dart';

class GetJobsUseCase {
  final JobRepository repository;

  GetJobsUseCase(this.repository);

  Future<Either<Failure, List<Job>>> call() async {
    return await repository.getJobs();
  }
}