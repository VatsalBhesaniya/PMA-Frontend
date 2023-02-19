part of 'project_bloc.dart';

@freezed
class ProjectEvent with _$ProjectEvent {
  const factory ProjectEvent.fetchProject({
    required int projectId,
  }) = _FetchProject;
}
