import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:jobportal_app/features/auth/presentation/manager/auth_bloc.dart';
import 'package:jobportal_app/features/auth/presentation/manager/auth_event.dart';
import 'package:jobportal_app/features/auth/presentation/manager/auth_state.dart';
import 'package:jobportal_app/features/auth/presentation/pages/login_page.dart';
import 'package:jobportal_app/features/auth/presentation/widgets/login_form.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const LoginPage(),
      ),
    );
  }

  testWidgets('should render LoginForm when state is AuthInitial', (WidgetTester tester) async {
    when(mockAuthBloc.state).thenReturn(AuthInitial());
    whenListen(
      mockAuthBloc,
      Stream.fromIterable([AuthInitial()]),
    );

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(LoginForm), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
  });

  testWidgets('should render CircularProgressIndicator when state is AuthLoading', (WidgetTester tester) async {
    when(mockAuthBloc.state).thenReturn(AuthLoading());
    whenListen(
      mockAuthBloc,
      Stream.fromIterable([AuthLoading()]),
    );

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('should show SnackBar when state is AuthError', (WidgetTester tester) async {
    when(mockAuthBloc.state).thenReturn(AuthInitial());
    whenListen(
      mockAuthBloc,
      Stream.fromIterable([const AuthError('Test Error')]),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    
    // Trigger the listener by emitting error state
    mockAuthBloc.emit(const AuthError('Test Error'));
    await tester.pump(); // Start animation
    await tester.pump(const Duration(milliseconds: 750)); // Wait for snackbar

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Test Error'), findsOneWidget);
  });
}
