part of 'task_bloc.dart';

@freezed
class TaskState with _$TaskState {
  const factory TaskState.initial() = _Initial;
  const factory TaskState.loadInProgress() = _LoadInProgress;
  const factory TaskState.fetchTaskSuccess({
    required Task task,
  }) = _FetchTaskSuccess;
  const factory TaskState.fetchTaskFailure() = _FetchTaskFailure;
}
