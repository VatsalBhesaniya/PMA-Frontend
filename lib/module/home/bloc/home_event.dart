part of 'home_bloc.dart';

@freezed
class HomeEvent with _$HomeEvent {
  const factory HomeEvent.fetchProjects() = _FetchProjects;
  const factory HomeEvent.createProject({
    required CreateProject project,
  }) = _CreateProject;
}
