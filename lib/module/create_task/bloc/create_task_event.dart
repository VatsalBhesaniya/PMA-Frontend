part of 'create_task_bloc.dart';

@freezed
class CreateTaskEvent with _$CreateTaskEvent {
  const factory CreateTaskEvent.createTask({
    required CreateTask task,
  }) = _CreateTask;
}
