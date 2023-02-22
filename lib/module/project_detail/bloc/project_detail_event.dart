part of 'project_detail_bloc.dart';

@freezed
class ProjectDetailEvent with _$ProjectDetailEvent {
  const factory ProjectDetailEvent.fetchProjectDetail({
    required int projectId,
  }) = _FetchProjectDetail;
  const factory ProjectDetailEvent.editProjectDetail({
    required ProjectDetail projectDetail,
  }) = _EditProjectDetail;
  const factory ProjectDetailEvent.updateProjectDetail({
    required ProjectDetail projectDetail,
  }) = _UpdateProjectDetail;
  const factory ProjectDetailEvent.removeMember({
    required int projectId,
    required int userId,
  }) = _RemoveMember;
  const factory ProjectDetailEvent.deleteProject({
    required int projectId,
  }) = _DeleteProject;
}
