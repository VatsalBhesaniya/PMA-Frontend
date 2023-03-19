part of 'invited_projects_bloc.dart';

@freezed
class InvitedProjectsState with _$InvitedProjectsState {
  const factory InvitedProjectsState.initial() = _Initial;
  const factory InvitedProjectsState.loadInProgress() = _LoadInProgress;
  const factory InvitedProjectsState.fetchInvitedProjectsSuccess({
    required List<Project> projects,
  }) = _FetchInvitedProjectsSuccess;
  const factory InvitedProjectsState.fetchInvitedProjectsFailure({
    required NetworkExceptions error,
  }) = _FetchInvitedProjectsFailure;
}
