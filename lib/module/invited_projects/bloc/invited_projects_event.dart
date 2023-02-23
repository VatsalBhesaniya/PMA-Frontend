part of 'invited_projects_bloc.dart';

@freezed
class InvitedProjectsEvent with _$InvitedProjectsEvent {
  const factory InvitedProjectsEvent.fetchInvitedProjects() =
      _FetchInvitedProjects;
}
