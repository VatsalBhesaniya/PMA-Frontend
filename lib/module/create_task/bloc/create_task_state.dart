part of 'create_task_bloc.dart';

@freezed
class CreateTaskState with _$CreateTaskState {
  const factory CreateTaskState.initial() = _Initial;
  const factory CreateTaskState.loadInProgress() = _LoadInProgress;
  const factory CreateTaskState.createTaskSuccess({
    required int taskId,
  }) = _CreateTaskSuccess;
  const factory CreateTaskState.createTaskFailure({
    required NetworkExceptions error,
  }) = _CreateTaskFailure;
}
