import '../../domain/entities/application.dart';

abstract class ApplicationState {}

class ApplicationInitial extends ApplicationState {}

class ApplicationLoading extends ApplicationState {}

class ApplicationsLoaded extends ApplicationState {
  final List<Application> applications;
  ApplicationsLoaded(this.applications);
}

class ApplicationActionSuccess extends ApplicationState {
  final String message;
  ApplicationActionSuccess(this.message);
}

class ApplicationError extends ApplicationState {
  final String message;
  ApplicationError(this.message);
}
