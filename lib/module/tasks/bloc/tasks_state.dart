part of 'tasks_bloc.dart';

@freezed
class TasksState with _$TasksState {
  const factory TasksState.initial() = _Initial;
  const factory TasksState.loadInProgress() = _LoadInProgress;
  const factory TasksState.fetchTasksSuccess({
    required List<Task> tasks,
  }) = _FetchTasksSuccess;
  const factory TasksState.fetchTasksFailure() = _FetchTasksFailure;
}
