part of 'invite_members_bloc.dart';

@freezed
class InviteMembersEvent with _$InviteMembersEvent {
  const factory InviteMembersEvent.inviteMembers({
    required List<SearchUser> users,
    required int projectId,
  }) = _InviteMembers;
}
