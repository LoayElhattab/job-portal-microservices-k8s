import 'package:dartz/dartz.dart';
import 'package:jobportal_app/core/errors/failures.dart';
import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, Profile>> getProfile();
}