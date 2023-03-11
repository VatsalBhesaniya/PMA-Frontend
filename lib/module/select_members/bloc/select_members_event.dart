part of 'select_members_bloc.dart';

@freezed
class SelectMembersEvent with _$SelectMembersEvent {
  const factory SelectMembersEvent.searchUsers({
    required String searchText,
    required int projectId,
    required int taskId,
  }) = _SearchUsers;
  const factory SelectMembersEvent.selectUser({
    required int index,
    required List<SearchUser> users,
  }) = _SelectUser;
}
