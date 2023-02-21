part of 'invite_members_bloc.dart';

@freezed
class InviteMembersEvent with _$InviteMembersEvent {
  const factory InviteMembersEvent.searchUsers({
    required String searchText,
  }) = _SearchUsers;
  const factory InviteMembersEvent.selectUser({
    required int index,
    required List<SearchUser> users,
  }) = _SelectUser;
  const factory InviteMembersEvent.inviteMembers({
    required List<SearchUser> users,
  }) = _InviteMembers;
}
