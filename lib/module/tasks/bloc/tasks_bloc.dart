import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/task.dart';
import 'package:pma/module/tasks/tasks_repository.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

part 'tasks_state.dart';
part 'tasks_event.dart';
part 'tasks_bloc.freezed.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  TasksBloc({
    required TasksRepository tasksRepository,
  })  : _tasksRepository = tasksRepository,
        super(const TasksState.initial()) {
    on<_FetchTasks>(_onFetchTasks);
    on<_DeleteTask>(_onDeleteTask);
  }

  final TasksRepository _tasksRepository;

  FutureOr<void> _onFetchTasks(
      _FetchTasks event, Emitter<TasksState> emit) async {
    emit(const _LoadInProgress());
    final ApiResult<List<Task>?> apiResult =
        await _tasksRepository.fetchTasks();
    apiResult.when(
      success: (List<Task>? tasks) {
        emit(_FetchTasksSuccess(tasks: tasks ?? <Task>[]));
      },
      failure: (NetworkExceptions error) {
        emit(const _FetchTasksFailure());
      },
    );
  }

  FutureOr<void> _onDeleteTask(
      _DeleteTask event, Emitter<TasksState> emit) async {
    emit(const _LoadInProgress());
    final ApiResult<bool> apiResult = await _tasksRepository.deleteTask(
      taskId: event.taskId,
    );
    apiResult.when(
      success: (bool isDeleted) {
        emit(const _DeleteTaskSuccess());
      },
      failure: (NetworkExceptions error) {
        emit(_DeleteTaskFailure(error: error));
      },
    );
  }
}
