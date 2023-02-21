part of 'home_bloc.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState.initial() = _Initial;
  const factory HomeState.loadInProgress() = _LoadInProgress;
  const factory HomeState.fetchProjectsSuccess({
    required List<Project> projects,
  }) = _FetchProjectsSuccess;
  const factory HomeState.fetchProjectsFailure() = _FetchProjectsFailure;
  const factory HomeState.createProjectSuccess() = _CreateProjectSuccess;
  const factory HomeState.createProjectFailure({
    required NetworkExceptions error,
  }) = _CreateProjectFailure;
}
