# Job Portal App - Test Suite

This directory contains automated tests for the Flutter frontend, following Clean Architecture principles.

## Structure

The test directory mirrors the `lib/` directory:
- `features/`: Unit and widget tests for each feature.
- `core/`: Tests for core utilities like networking and storage.
- `config/`: Tests for application configuration and environment loading.

## Running Tests

To run all tests, use the standard Flutter test command:

```bash
flutter test
```

## Mocking

We use `mockito` for mocking dependencies. Most mocks are defined in `test/helpers/mock_helper.dart`. 
If you add new dependencies that need mocking, update `mock_helper.dart` and run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

*Note: For environments where `build_runner` cannot be run, manual mocks (extending `Mock`) are used in individual test files.*

## BLoC Testing

We use the `bloc_test` package to verify state transitions in our BLoCs. Each BLoC test ensures that events trigger the correct sequence of states (e.g., `Loading` -> `Loaded` or `Loading` -> `Error`).
