import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/job.dart';
import '../repositories/job_repository.dart';

class CreateJobUseCase {
  final JobRepository repository;

  CreateJobUseCase(this.repository);

  Future<Either<Failure, Job>> call(
    String title,
    String description,
    String company,
    String location,
    String salary,
  ) async {
    return await repository.createJob(title, description, company, location, salary);
  }
}
