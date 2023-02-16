import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/document.dart';
import 'package:pma/models/note.dart';
import 'package:pma/models/task.dart';
import 'package:pma/module/task/task_repository.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

part 'task_state.dart';
part 'task_event.dart';
part 'task_bloc.freezed.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc({
    required TaskRepository taskRepository,
  })  : _taskRepository = taskRepository,
        super(const TaskState.initial()) {
    on<_FetchTask>(_onFetchTask);
    on<_EditTask>(_onEditTask);
    on<_UpdateTask>(_onUpdateTask);
    on<_FetchAttachedNotes>(_onFetchAttachedNotes);
    on<_ExpandTask>(_onExpandTask);
    on<_FetchAttachedDocuments>(_onFetchAttachedDocuments);
    on<_ExpandDocument>(_onExpandDocument);
  }

  final TaskRepository _taskRepository;

  FutureOr<void> _onFetchTask(_FetchTask event, Emitter<TaskState> emit) async {
    emit(const _LoadInProgress());
    final ApiResult<Task?> apiResult =
        await _taskRepository.fetchTask(taskId: event.taskId);
    apiResult.when(
      success: (Task? task) {
        if (task == null) {
          emit(const _FetchTaskFailure());
        } else {
          emit(_FetchTaskSuccess(task: task));
        }
      },
      failure: (NetworkExceptions error) {
        emit(const _FetchTaskFailure());
      },
    );
  }

  void _onEditTask(_EditTask event, Emitter<TaskState> emit) {
    emit(const _LoadInProgress());
    emit(_FetchTaskSuccess(task: event.task));
  }

  FutureOr<void> _onUpdateTask(
      _UpdateTask event, Emitter<TaskState> emit) async {
    emit(const _LoadInProgress());
    final ApiResult<Task?> apiResult =
        await _taskRepository.updateTask(task: event.task);
    apiResult.when(
      success: (Task? task) {
        if (task == null) {
          emit(const _UpdateTaskFailure());
        } else {
          emit(_FetchTaskSuccess(task: task));
        }
      },
      failure: (NetworkExceptions error) {
        emit(const _UpdateTaskFailure());
      },
    );
  }

  FutureOr<void> _onFetchAttachedNotes(
      _FetchAttachedNotes event, Emitter<TaskState> emit) async {
    emit(const _FetchAttachedNotesLoading());
    final ApiResult<List<Note>?> apiResult =
        await _taskRepository.fetchAttachedNotes(noteIds: event.noteIds);
    apiResult.when(
      success: (List<Note>? notes) {
        if (notes == null) {
          emit(const _FetchAttachedNotesFailure());
        } else {
          emit(_FetchAttachedNotesSuccess(notes: notes));
        }
      },
      failure: (NetworkExceptions error) {
        emit(const _FetchAttachedNotesFailure());
      },
    );
  }

  void _onExpandTask(_ExpandTask event, Emitter<TaskState> emit) {
    emit(const _FetchAttachedNotesLoading());
    emit(
      _FetchAttachedNotesSuccess(
        notes: event.notes,
      ),
    );
  }

  FutureOr<void> _onFetchAttachedDocuments(
      _FetchAttachedDocuments event, Emitter<TaskState> emit) async {
    emit(const _FetchAttachedDocumentsLoading());
    final ApiResult<List<Document>?> apiResult = await _taskRepository
        .fetchAttachedDocuments(documentIds: event.documentIds);
    apiResult.when(
      success: (List<Document>? documents) {
        if (documents == null) {
          emit(const _FetchAttachedDocumentsFailure());
        } else {
          emit(_FetchAttachedDocumentsSuccess(documents: documents));
        }
      },
      failure: (NetworkExceptions error) {
        emit(const _FetchAttachedDocumentsFailure());
      },
    );
  }

  void _onExpandDocument(_ExpandDocument event, Emitter<TaskState> emit) {
    emit(const _FetchAttachedDocumentsLoading());
    emit(
      _FetchAttachedDocumentsSuccess(
        documents: event.documents,
      ),
    );
  }
}
