import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:jobportal_app/features/applications/domain/entities/application.dart';
import 'package:jobportal_app/features/applications/presentation/manager/application_bloc.dart';
import 'package:jobportal_app/features/applications/presentation/manager/application_event.dart';
import 'package:jobportal_app/features/applications/presentation/manager/application_state.dart';
import '../../../../helpers/mock_helper.mocks.dart';

void main() {
  late ApplicationBloc applicationBloc;
  late MockGetApplicationsUseCase mockGetApplicationsUseCase;
  late MockApplyForJobUseCase mockApplyForJobUseCase;
  late MockUpdateApplicationStatusUseCase mockUpdateStatusUseCase;

  setUp(() {
    mockGetApplicationsUseCase = MockGetApplicationsUseCase();
    mockApplyForJobUseCase = MockApplyForJobUseCase();
    mockUpdateStatusUseCase = MockUpdateApplicationStatusUseCase();
    applicationBloc = ApplicationBloc(
      getApplicationsUseCase: mockGetApplicationsUseCase,
      applyForJobUseCase: mockApplyForJobUseCase,
      updateStatusUseCase: mockUpdateStatusUseCase,
    );
  });

  tearDown(() {
    applicationBloc.close();
  });

  final tApplications = [
    Application(
      id: 1,
      jobId: 1,
      seekerId: 1,
      employerId: 1,
      status: 'pending',
      createdAt: DateTime.now(),
    )
  ];

  test('initial state should be ApplicationInitial', () {
    expect(applicationBloc.state, isA<ApplicationInitial>());
  });

  group('LoadApplications', () {
    blocTest<ApplicationBloc, ApplicationState>(
      'emits [ApplicationLoading, ApplicationsLoaded] when successful',
      build: () {
        when(mockGetApplicationsUseCase()).thenAnswer((_) async => tApplications);
        return applicationBloc;
      },
      act: (bloc) => bloc.add(LoadApplications()),
      expect: () => [
        isA<ApplicationLoading>(),
        isA<ApplicationsLoaded>(),
      ],
    );

    blocTest<ApplicationBloc, ApplicationState>(
      'emits [ApplicationLoading, ApplicationError] when failure occurs',
      build: () {
        when(mockGetApplicationsUseCase()).thenThrow(Exception());
        return applicationBloc;
      },
      act: (bloc) => bloc.add(LoadApplications()),
      expect: () => [
        isA<ApplicationLoading>(),
        isA<ApplicationError>(),
      ],
    );
  });

  group('ApplyForJobEvent', () {
    blocTest<ApplicationBloc, ApplicationState>(
      'emits [ApplicationLoading, ApplicationActionSuccess] when successful',
      build: () {
        when(mockApplyForJobUseCase(1, 1, 'Hi')).thenAnswer((_) async => tApplications[0]);
        when(mockGetApplicationsUseCase()).thenAnswer((_) async => tApplications);
        return applicationBloc;
      },
      act: (bloc) => bloc.add(ApplyForJobEvent(jobId: 1, employerId: 1, coverLetter: 'Hi')),
      expect: () => [
        isA<ApplicationLoading>(),
        isA<ApplicationActionSuccess>(),
        isA<ApplicationLoading>(), // From LoadApplications() trigger
        isA<ApplicationsLoaded>(),
      ],
    );

    blocTest<ApplicationBloc, ApplicationState>(
      'emits [ApplicationLoading, ApplicationError] on duplicate application',
      build: () {
        when(mockApplyForJobUseCase(1, 1, 'Hi')).thenThrow(Exception('DUPLICATE_ENTRY'));
        return applicationBloc;
      },
      act: (bloc) => bloc.add(ApplyForJobEvent(jobId: 1, employerId: 1, coverLetter: 'Hi')),
      expect: () => [
        isA<ApplicationLoading>(),
        isA<ApplicationError>(),
      ],
    );
  });
}
