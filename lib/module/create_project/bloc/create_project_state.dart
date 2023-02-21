part of 'create_project_bloc.dart';

@freezed
class CreateProjectState with _$CreateProjectState {
  const factory CreateProjectState.initial() = _Initial;
  const factory CreateProjectState.loadInProgress() = _LoadInProgress;
  const factory CreateProjectState.createProjectSuccess() =
      _CreateProjectSuccess;
  const factory CreateProjectState.createProjectFailure({
    required NetworkExceptions error,
  }) = _CreateProjectFailure;
}
