part of 'my_projects_bloc.dart';

@freezed
class MyProjectsState with _$MyProjectsState {
  const factory MyProjectsState.initial() = _Initial;
  const factory MyProjectsState.loadInProgress() = _LoadInProgress;
  const factory MyProjectsState.fetchProjectsSuccess({
    required List<Project> projects,
  }) = _FetchProjectsSuccess;
  const factory MyProjectsState.fetchProjectsFailure({
    required NetworkExceptions error,
  }) = _FetchProjectsFailure;
  const factory MyProjectsState.createProjectSuccess() = _CreateProjectSuccess;
  const factory MyProjectsState.createProjectFailure({
    required NetworkExceptions error,
  }) = _CreateProjectFailure;
}
