part of 'assign_task_bloc.dart';

@freezed
class AssignTaskState with _$AssignTaskState {
  const factory AssignTaskState.initial() = _Initial;
  const factory AssignTaskState.loadInProgress() = _LoadInProgress;
  const factory AssignTaskState.assignTaskToMemberSuccess() =
      _AssignMemberSuccess;
  const factory AssignTaskState.assignTaskToMemberFailure({
    required NetworkExceptions error,
  }) = _assignMemberFailure;
}
