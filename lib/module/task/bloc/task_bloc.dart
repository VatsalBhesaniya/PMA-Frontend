import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/attach_document.dart';
import 'package:pma/models/attach_note.dart';
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
    on<_DeleteTask>(_onDeleteTask);
    on<_FetchAttachedNotes>(_onFetchAttachedNotes);
    on<_ExpandTask>(_onExpandTask);
    on<_FetchAttachedDocuments>(_onFetchAttachedDocuments);
    on<_ExpandDocument>(_onExpandDocument);
    on<_RemoveMember>(_onRemoveMember);
    on<_FetchProjectNotes>(_onFetchProjectNotes);
    on<_SelectNote>(_onSelectNote);
    on<_FetchProjectDocuments>(_onFetchProjectDocuments);
    on<_SelectDocument>(_onSelectDocument);
    on<_AttachNotes>(_onAttachNotes);
    on<_RemoveAttachedNote>(_onRemoveAttachedNote);
    on<_AttachDocuments>(_onAttachDocuments);
    on<_RemoveAttachedDocument>(_onRemoveAttachedDocument);
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

  FutureOr<void> _onDeleteTask(
      _DeleteTask event, Emitter<TaskState> emit) async {
    emit(const _LoadInProgress());
    final ApiResult<bool> apiResult = await _taskRepository.deleteTask(
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

  FutureOr<void> _onFetchAttachedNotes(
      _FetchAttachedNotes event, Emitter<TaskState> emit) async {
    emit(const _FetchAttachedNotesLoading());
    final ApiResult<List<Note>> apiResult =
        await _taskRepository.fetchAttachedNotes(noteIds: event.noteIds);
    apiResult.when(
      success: (List<Note> notes) {
        emit(_FetchAttachedNotesSuccess(notes: notes));
      },
      failure: (NetworkExceptions error) {
        emit(_FetchAttachedNotesFailure(error: error));
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
    final ApiResult<List<Document>> apiResult = await _taskRepository
        .fetchAttachedDocuments(documentIds: event.documentIds);
    apiResult.when(
      success: (List<Document> documents) {
        emit(_FetchAttachedDocumentsSuccess(documents: documents));
      },
      failure: (NetworkExceptions error) {
        emit(_FetchAttachedDocumentsFailure(error: error));
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

  FutureOr<void> _onRemoveMember(
      _RemoveMember event, Emitter<TaskState> emit) async {
    emit(const _LoadInProgress());
    final ApiResult<void> apiResult =
        await _taskRepository.removeAssignedMember(
      taskId: event.taskId,
      projectId: event.projectId,
      userId: event.userId,
    );
    apiResult.when(
      success: (void value) {
        emit(
          const TaskState.removeMemberSuccess(),
        );
      },
      failure: (NetworkExceptions error) {
        emit(
          TaskState.removeMemberFailure(error: error),
        );
      },
    );
  }

  FutureOr<void> _onFetchProjectNotes(
      _FetchProjectNotes event, Emitter<TaskState> emit) async {
    emit(const _BottomSheetLoadInProgress());
    final ApiResult<List<Note>> apiResult =
        await _taskRepository.fetchProjectNotes(
      taskId: event.taskId,
      projectId: event.projectId,
    );
    apiResult.when(
      success: (List<Note> notes) {
        emit(
          TaskState.fetchProjectNotesSuccess(
            notes: notes,
          ),
        );
      },
      failure: (NetworkExceptions error) {
        emit(
          TaskState.fetchProjectNotesFailure(error: error),
        );
      },
    );
  }

  FutureOr<void> _onFetchProjectDocuments(
      _FetchProjectDocuments event, Emitter<TaskState> emit) async {
    emit(const _BottomSheetLoadInProgress());
    final ApiResult<List<Document>> apiResult =
        await _taskRepository.fetchProjectDocuments(
      taskId: event.taskId,
      projectId: event.projectId,
    );
    apiResult.when(
      success: (List<Document> documents) {
        emit(
          TaskState.fetchProjectDocumentsSuccess(
            documents: documents,
          ),
        );
      },
      failure: (NetworkExceptions error) {
        emit(
          TaskState.fetchProjectDocumentsFailure(error: error),
        );
      },
    );
  }

  FutureOr<void> _onSelectNote(_SelectNote event, Emitter<TaskState> emit) {
    emit(const _BottomSheetLoadInProgress());
    final List<Note> notes = List<Note>.from(event.notes);
    final Note note = notes[event.index];
    notes[event.index] = note.copyWith(isSelected: !note.isSelected);
    emit(
      TaskState.fetchProjectNotesSuccess(
        notes: notes,
      ),
    );
  }

  FutureOr<void> _onSelectDocument(
      _SelectDocument event, Emitter<TaskState> emit) {
    emit(const _BottomSheetLoadInProgress());
    final List<Document> documents = List<Document>.from(event.documents);
    final Document document = documents[event.index];
    documents[event.index] =
        document.copyWith(isSelected: !document.isSelected);
    emit(
      TaskState.fetchProjectDocumentsSuccess(
        documents: documents,
      ),
    );
  }

  FutureOr<void> _onAttachNotes(
      _AttachNotes event, Emitter<TaskState> emit) async {
    final List<Map<String, dynamic>> notesData = <Map<String, dynamic>>[];
    for (final Note note in event.notes) {
      final AttachNote attachNote = AttachNote(
        taskId: event.taskId,
        noteId: note.id,
      );
      notesData.add(attachNote.toJson());
    }
    final ApiResult<void> apiResult = await _taskRepository.attachNotes(
      notesData: notesData,
    );
    apiResult.when(
      success: (void value) {
        emit(const TaskState.attachNotesSuccess());
      },
      failure: (NetworkExceptions error) {
        emit(TaskState.attachNotesFailure(error: error));
      },
    );
  }

  FutureOr<void> _onAttachDocuments(
      _AttachDocuments event, Emitter<TaskState> emit) async {
    final List<Map<String, dynamic>> documentsData = <Map<String, dynamic>>[];
    for (final Document document in event.documents) {
      final AttachDocument attacheDocument = AttachDocument(
        taskId: event.taskId,
        documentId: document.id,
      );
      documentsData.add(attacheDocument.toJson());
    }
    final ApiResult<void> apiResult = await _taskRepository.attachDocuments(
      documentsData: documentsData,
    );
    apiResult.when(
      success: (void value) {
        emit(const TaskState.attachDocumentsSuccess());
      },
      failure: (NetworkExceptions error) {
        emit(TaskState.attachDocumentFailure(error: error));
      },
    );
  }

  FutureOr<void> _onRemoveAttachedNote(
      _RemoveAttachedNote event, Emitter<TaskState> emit) async {
    final ApiResult<void> apiResult = await _taskRepository.removeAttachedNote(
      attachedNoteData: event.attachNote.toJson(),
    );
    apiResult.when(
      success: (void value) {
        emit(const TaskState.removeAttachedNoteSuccess());
      },
      failure: (NetworkExceptions error) {
        emit(TaskState.removeAttachedNoteFailure(error: error));
      },
    );
  }

  FutureOr<void> _onRemoveAttachedDocument(
      _RemoveAttachedDocument event, Emitter<TaskState> emit) async {
    final ApiResult<void> apiResult =
        await _taskRepository.removeAttachedDocument(
      attachedDocumentData: event.attachDocument.toJson(),
    );
    apiResult.when(
      success: (void value) {
        emit(const TaskState.removeAttachedDocumentSuccess());
      },
      failure: (NetworkExceptions error) {
        emit(TaskState.removeAttachedDocumentFailure(error: error));
      },
    );
  }
}
