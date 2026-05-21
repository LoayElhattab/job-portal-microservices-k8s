import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class GetProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final String name;
  final String bio;
  final List<String>? skills;

  UpdateProfileEvent({required this.name, required this.bio, this.skills});

  @override
  List<Object> get props => [name, bio, skills ?? []];
}