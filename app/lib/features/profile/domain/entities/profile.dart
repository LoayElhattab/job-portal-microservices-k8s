import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;
  final String bio;
  final List<String> skills;

  const Profile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.bio = "No bio available",
    this.skills = const [],
  });

  @override
  List<Object?> get props => [id, name, email, role, bio, skills];
}