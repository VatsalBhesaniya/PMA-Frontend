import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/create_task.dart';
import 'package:pma/module/create_task/create_task_repository.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

part 'create_task_state.dart';
part 'create_task_event.dart';
part 'create_task_bloc.freezed.dart';

class CreateTaskBloc extends Bloc<CreateTaskEvent, CreateTaskState> {
  CreateTaskBloc({
    required CreateTaskRepository createTaskRepository,
  })  : _createTaskRepository = createTaskRepository,
        super(const CreateTaskState.initial()) {
    on<_CreateTask>(_onCreateTask);
  }

  final CreateTaskRepository _createTaskRepository;

  FutureOr<void> _onCreateTask(
      _CreateTask event, Emitter<CreateTaskState> emit) async {
    emit(const CreateTaskState.loadInProgress());
    final ApiResult<int> apiResult = await _createTaskRepository.createTask(
      taskData: event.task.toJson(),
    );
    apiResult.when(
      success: (int taskId) {
        emit(
          CreateTaskState.createTaskSuccess(taskId: taskId),
        );
      },
      failure: (NetworkExceptions error) {
        emit(
          const CreateTaskState.createTaskFailure(
            error: NetworkExceptions.defaultError(),
          ),
        );
      },
    );
  }
}
