import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:jobportal_app/core/errors/failures.dart';
import 'package:jobportal_app/features/profile/domain/entities/profile.dart';
import 'package:jobportal_app/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:jobportal_app/features/profile/presentation/manager/profile_bloc.dart';
import 'package:jobportal_app/features/profile/presentation/manager/profile_event.dart';
import 'package:jobportal_app/features/profile/presentation/manager/profile_state.dart';

class MockGetProfileUseCase extends Mock implements GetProfileUseCase {}

void main() {
  late ProfileBloc profileBloc;
  late MockGetProfileUseCase mockGetProfileUseCase;

  setUp(() {
    mockGetProfileUseCase = MockGetProfileUseCase();
    profileBloc = ProfileBloc(getProfileUseCase: mockGetProfileUseCase);
  });

  tearDown(() {
    profileBloc.close();
  });

  const tProfile = Profile(
    id: '1',
    name: 'John Doe',
    email: 'john@example.com',
    role: 'seeker',
  );

  test('initial state should be ProfileInitial', () {
    expect(profileBloc.state, isA<ProfileInitial>());
  });

  group('GetProfileEvent', () {
    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileLoaded] when successful',
      build: () {
        when(mockGetProfileUseCase()).thenAnswer((_) async => const Right(tProfile));
        return profileBloc;
      },
      act: (bloc) => bloc.add(GetProfileEvent()),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileLoaded>(),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileError] when failure occurs',
      build: () {
        when(mockGetProfileUseCase()).thenAnswer((_) async => Left(ServerFailure()));
        return profileBloc;
      },
      act: (bloc) => bloc.add(GetProfileEvent()),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileError>(),
      ],
    );
  });
}
