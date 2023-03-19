part of 'project_bloc.dart';

@freezed
class ProjectState with _$ProjectState {
  const factory ProjectState.initial() = _Initial;
  const factory ProjectState.loadInProgress() = _LoadInProgress;
  const factory ProjectState.fetchProjectSuccess({
    required Project project,
  }) = _FetchProjectSuccess;
  const factory ProjectState.fetchProjectFailure({
    required NetworkExceptions error,
  }) = _FetchProjectFailure;
}
