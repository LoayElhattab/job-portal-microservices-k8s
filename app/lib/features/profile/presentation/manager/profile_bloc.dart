import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;

  ProfileBloc({required this.getProfileUseCase}) : super(ProfileInitial()) {
    on<GetProfileEvent>((event, emit) async {
      emit(ProfileLoading());

      // استدعاء الـ UseCase الذي يكلم الـ Repository
      final result = await getProfileUseCase();

      result.fold(
            (failure) => emit(const ProfileError(message: 'ERROR')),
            (profile) => emit(ProfileLoaded(profile: profile)),
      );
    });
  }
}