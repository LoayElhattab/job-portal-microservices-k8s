import 'package:dio/dio.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<ProfileModel> updateProfile(String name, String bio, List<String>? skills);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;
  ProfileRemoteDataSourceImpl({required this.dio});

  @override
  Future<ProfileModel> getProfile() async {
    final response = await dio.get('/users/profile');
    if (response.statusCode == 200) {
      return ProfileModel.fromJson(response.data['data']['user']);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  @override
  Future<ProfileModel> updateProfile(String name, String bio, List<String>? skills) async {
    final response = await dio.patch(
      '/users/profile',
      data: {
        'name': name,
        'bio': bio,
        if (skills != null) 'skills': skills,
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return ProfileModel.fromJson(response.data['data']['user']);
    } else {
      throw Exception('Failed to update profile');
    }
  }
}
