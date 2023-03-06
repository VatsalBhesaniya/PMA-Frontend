part of 'select_members_bloc.dart';

@freezed
class SelectMembersState with _$SelectMembersState {
  const factory SelectMembersState.initial() = _Initial;
  const factory SelectMembersState.loadInProgress() = _LoadInProgress;
  const factory SelectMembersState.searchUsersSuccess({
    required List<SearchUser> users,
  }) = _SearchUsersSuccess;
  const factory SelectMembersState.searchUsersFailure({
    required NetworkExceptions error,
  }) = _SearchUsersFailure;
}
