part of 'assign_task_bloc.dart';

@freezed
class AssignTaskEvent with _$AssignTaskEvent {
  const factory AssignTaskEvent.assignTaskToMember({
    required int taskId,
    required int projectId,
    required List<SearchUser> users,
  }) = _AssignMember;
}
