import 'package:dio/dio.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;
  ProfileRemoteDataSourceImpl({required this.dio});

  @override
  Future<ProfileModel> getProfile() async {
    final response = await dio.get('/api/v1/users/profile');
    if (response.statusCode == 200) {
      return ProfileModel.fromJson(response.data['data']);
    } else {
      throw Exception();
    }
  }
}