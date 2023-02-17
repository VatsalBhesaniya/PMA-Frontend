part of 'tasks_bloc.dart';

@freezed
class TasksEvent with _$TasksEvent {
  const factory TasksEvent.fetchTasks() = _FetchTasks;
  const factory TasksEvent.deleteTask({
    required int taskId,
  }) = _DeleteTask;
}
