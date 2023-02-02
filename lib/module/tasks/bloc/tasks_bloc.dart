import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/task.dart';
import 'package:pma/module/tasks/tasks_repository.dart';

part 'tasks_state.dart';
part 'tasks_event.dart';
part 'tasks_bloc.freezed.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  TasksBloc({
    required TasksRepository tasksRepository,
  })  : _tasksRepository = tasksRepository,
        super(const TasksState.initial()) {
    on<_FetchTasks>(_onFetchTasks);
  }

  final TasksRepository _tasksRepository;

  FutureOr<void> _onFetchTasks(
      _FetchTasks event, Emitter<TasksState> emit) async {
    emit(const _LoadInProgress());
    final List<Task>? result = await _tasksRepository.fetchTasks();
    if (result == null) {
      emit(const _FetchTasksFailure());
    } else {
      emit(_FetchTasksSuccess(tasks: result));
    }
  }
}