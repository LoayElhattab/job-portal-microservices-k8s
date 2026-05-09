import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:jobportal_app/core/errors/failures.dart';
import 'package:jobportal_app/features/job/domain/entities/job.dart';
import 'package:jobportal_app/features/job/presentation/manager/job_bloc.dart';
import '../../../helpers/mock_helper.mocks.dart';

void main() {
  late JobBloc jobBloc;
  late MockGetJobsUseCase mockGetJobsUseCase;

  setUp(() {
    mockGetJobsUseCase = MockGetJobsUseCase();
    jobBloc = JobBloc(getJobsUseCase: mockGetJobsUseCase);
  });

  tearDown(() {
    jobBloc.close();
  });

  final tJobs = [
    Job(
      id: '1',
      title: 'Job 1',
      description: 'Desc 1',
      companyName: 'Co 1',
      location: 'Loc 1',
      salary: 100.0,
      requirements: const [],
    )
  ];

  test('initial state should be JobInitial', () {
    expect(jobBloc.state, isA<JobInitial>());
  });

  group('GetJobsEvent', () {
    blocTest<JobBloc, JobState>(
      'emits [JobLoading, JobLoaded] when get jobs is successful',
      build: () {
        when(mockGetJobsUseCase()).thenAnswer((_) async => Right(tJobs));
        return jobBloc;
      },
      act: (bloc) => bloc.add(GetJobsEvent()),
      expect: () => [
        isA<JobLoading>(),
        isA<JobLoaded>(),
      ],
    );

    blocTest<JobBloc, JobState>(
      'emits [JobLoading, JobError] when get jobs fails',
      build: () {
        when(mockGetJobsUseCase()).thenAnswer((_) async => Left(ServerFailure()));
        return jobBloc;
      },
      act: (bloc) => bloc.add(GetJobsEvent()),
      expect: () => [
        isA<JobLoading>(),
        isA<JobError>(),
      ],
    );
  });
}
