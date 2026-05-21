import 'package:dartz/dartz.dart';
import 'package:jobportal_app/core/errors/failures.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;
  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, Profile>> call(String name, String bio, List<String>? skills) async {
    return await repository.updateProfile(name: name, bio: bio, skills: skills);
  }
}
