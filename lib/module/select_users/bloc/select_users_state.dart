part of 'select_users_bloc.dart';

@freezed
class SelectUsersState with _$SelectUsersState {
  const factory SelectUsersState.initial() = _Initial;
  const factory SelectUsersState.loadInProgress() = _LoadInProgress;
  const factory SelectUsersState.searchUsersSuccess({
    required List<SearchUser> users,
  }) = _SearchUsersSuccess;
  const factory SelectUsersState.searchUsersFailure({
    required NetworkExceptions error,
  }) = _SearchUsersFailure;
}
