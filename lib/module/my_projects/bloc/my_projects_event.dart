part of 'my_projects_bloc.dart';

@freezed
class MyProjectsEvent with _$MyProjectsEvent {
  const factory MyProjectsEvent.fetchProjects() = _FetchProjects;
  const factory MyProjectsEvent.createProject({
    required CreateProject project,
  }) = _CreateProject;
}
