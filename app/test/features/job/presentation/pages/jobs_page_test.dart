import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jobportal_app/features/job/domain/entities/job.dart';
import 'package:jobportal_app/features/job/presentation/manager/job_bloc.dart';
import 'package:jobportal_app/features/job/presentation/pages/jobs_page.dart';

class MockJobBloc extends MockBloc<JobEvent, JobState> implements JobBloc {}

void main() {
  late MockJobBloc mockJobBloc;

  setUp(() {
    mockJobBloc = MockJobBloc();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<JobBloc>.value(
        value: mockJobBloc,
        child: const JobsPage(),
      ),
    );
  }

  final tJobs = [
    Job(
      id: '1',
      employerId: '10',
      title: 'Test Job',
      description: 'Desc',
      companyName: 'Co',
      location: 'Loc',
      salary: '100.0',
      requirements: const [],
    )
  ];

  testWidgets('should render Jobs Dashboard title', (WidgetTester tester) async {
    when(() => mockJobBloc.state).thenReturn(JobInitial());
    whenListen(
      mockJobBloc,
      Stream.fromIterable([JobInitial()]),
      initialState: JobInitial(),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('Jobs Dashboard'), findsOneWidget);
  });

  testWidgets('should render CircularProgressIndicator when state is JobLoading', (WidgetTester tester) async {
    when(() => mockJobBloc.state).thenReturn(JobLoading());
    whenListen(
      mockJobBloc,
      Stream.fromIterable([JobLoading()]),
      initialState: JobLoading(),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('should render job items when state is JobLoaded', (WidgetTester tester) async {
    when(() => mockJobBloc.state).thenReturn(JobLoaded(jobs: tJobs));
    whenListen(
      mockJobBloc,
      Stream.fromIterable([JobLoaded(jobs: tJobs)]),
      initialState: JobLoaded(jobs: tJobs),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text('Test Job'), findsOneWidget);
  });

  testWidgets('should render error message and retry button when state is JobError', (WidgetTester tester) async {
    when(() => mockJobBloc.state).thenReturn(const JobError(message: 'Server Error'));
    whenListen(
      mockJobBloc,
      Stream.fromIterable([const JobError(message: 'Server Error')]),
      initialState: const JobError(message: 'Server Error'),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text('Server Error'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
