import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/document.dart';
import 'package:pma/models/note.dart';
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
    on<_FetchAttachedNotes>(_onFetchAttachedNotes);
    on<_ExpandTask>(_onExpandTask);
    on<_FetchAttachedDocuments>(_onFetchAttachedDocuments);
    on<_ExpandDocument>(_onExpandDocument);
  }

  final TaskRepository _taskRepository;

  FutureOr<void> _onFetchTask(_FetchTask event, Emitter<TaskState> emit) async {
    emit(const _LoadInProgress());
    final Task? task = await _taskRepository.fetchTask(taskId: event.taskId);
    if (task == null) {
      emit(const _FetchTaskFailure());
    } else {
      emit(_FetchTaskSuccess(task: task));
    }
  }

  FutureOr<void> _onFetchAttachedNotes(
      _FetchAttachedNotes event, Emitter<TaskState> emit) async {
    emit(const _FetchAttachedNotesLoading());
    final List<Note>? notes =
        await _taskRepository.fetchAttachedNotes(noteIds: event.noteIds);
    if (notes == null) {
      emit(const _FetchAttachedNotesFailure());
    } else {
      emit(_FetchAttachedNotesSuccess(notes: notes));
    }
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
    final List<Document>? documents = await _taskRepository
        .fetchAttachedDocuments(documentIds: event.documentIds);
    if (documents == null) {
      emit(const _FetchAttachedDocumentsFailure());
    } else {
      emit(_FetchAttachedDocumentsSuccess(documents: documents));
    }
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
