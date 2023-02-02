import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/task.dart';
import 'package:pma/module/task/task_repository.dart';

part 'task_state.dart';
part 'task_event.dart';
part 'task_bloc.freezed.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc({
    required TaskRepository taskRepository,
  })  : _taskRepository = taskRepository,
        super(const TaskState.initial()) {
    on<_FetchTask>(_onFetchTask);
  }

  final TaskRepository _taskRepository;

  FutureOr<void> _onFetchTask(_FetchTask event, Emitter<TaskState> emit) async {
    emit(const _LoadInProgress());
    final Task? result = await _taskRepository.fetchTask(taskId: event.taskId);
    if (result == null) {
      emit(const _FetchTaskFailure());
    } else {
      emit(_FetchTaskSuccess(task: result));
    }
  }
}
