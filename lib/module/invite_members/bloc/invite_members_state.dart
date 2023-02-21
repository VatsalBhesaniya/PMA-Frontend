part of 'invite_members_bloc.dart';

@freezed
class InviteMembersState with _$InviteMembersState {
  const factory InviteMembersState.initial() = _Initial;
  const factory InviteMembersState.loadInProgress() = _LoadInProgress;
  const factory InviteMembersState.searchUsersSuccess({
    required List<SearchUser> users,
  }) = _SearchUsersSuccess;
  const factory InviteMembersState.searchUsersFailure({
    required NetworkExceptions error,
  }) = _SearchUsersFailure;
  const factory InviteMembersState.inviteMembersSuccess() =
      _InviteMembersSuccess;
  const factory InviteMembersState.inviteMembersFailure({
    required NetworkExceptions error,
  }) = _inviteMembersFailure;
}
