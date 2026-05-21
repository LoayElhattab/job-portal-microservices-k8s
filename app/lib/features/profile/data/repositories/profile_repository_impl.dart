import 'package:dartz/dartz.dart';
import 'package:jobportal_app/core/errors/failures.dart';
import 'package:jobportal_app/features/profile/domain/entities/profile.dart';
import 'package:jobportal_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:jobportal_app/features/profile/data/datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Profile>> getProfile() async {
    try {
      final remoteProfile = await remoteDataSource.getProfile();
      return Right(remoteProfile);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Profile>> updateProfile({required String name, required String bio, List<String>? skills}) async {
    try {
      final remoteProfile = await remoteDataSource.updateProfile(name, bio, skills);
      return Right(remoteProfile);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
