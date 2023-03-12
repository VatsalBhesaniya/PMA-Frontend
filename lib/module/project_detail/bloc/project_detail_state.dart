part of 'project_detail_bloc.dart';

@freezed
class ProjectDetailState with _$ProjectDetailState {
  const factory ProjectDetailState.initial() = _Initial;
  const factory ProjectDetailState.loadInProgress() = _LoadInProgress;
  const factory ProjectDetailState.fetchProjectDetailSuccess({
    required ProjectDetail projectDetail,
  }) = _FetchProjectDetailSuccess;
  const factory ProjectDetailState.fetchProjectDetailFailure({
    required NetworkExceptions error,
  }) = _FetchProjectDetailFailure;
  const factory ProjectDetailState.updateProjectDetailFailure({
    required NetworkExceptions error,
  }) = _UpdateProjectDetailFailure;
  const factory ProjectDetailState.updateProjectMemberRoleFailure({
    required NetworkExceptions error,
  }) = _UpdateProjectMemberRoleFailure;
  const factory ProjectDetailState.removeMemberSuccess() = _RemoveMemberSuccess;
  const factory ProjectDetailState.removeMemberFailure({
    required NetworkExceptions error,
  }) = _RemoveMemberFailure;
  const factory ProjectDetailState.deleteProjectSuccess() =
      _DeleteProjectSuccess;
  const factory ProjectDetailState.deleteProjectFailure({
    required NetworkExceptions error,
  }) = _DeleteProjectFailure;
}
