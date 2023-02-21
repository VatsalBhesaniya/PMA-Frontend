part of 'select_users_bloc.dart';

@freezed
class SelectUsersEvent with _$SelectUsersEvent {
  const factory SelectUsersEvent.searchUsers({
    required String searchText,
  }) = _SearchUsers;
  const factory SelectUsersEvent.selectUser({
    required int index,
    required List<SearchUser> users,
  }) = _SelectUser;
}
