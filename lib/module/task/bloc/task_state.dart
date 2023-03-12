part of 'task_bloc.dart';

@freezed
class TaskState with _$TaskState {
  const factory TaskState.initial() = _Initial;
  const factory TaskState.loadInProgress() = _LoadInProgress;
  const factory TaskState.fetchTaskSuccess({
    required Task task,
  }) = _FetchTaskSuccess;
  const factory TaskState.fetchTaskFailure({
    required NetworkExceptions error,
  }) = _FetchTaskFailure;
  const factory TaskState.updateTaskFailure({
    required NetworkExceptions error,
  }) = _UpdateTaskFailure;
  const factory TaskState.deleteTaskSuccess() = _DeleteTaskSuccess;
  const factory TaskState.deleteTaskFailure({
    required NetworkExceptions error,
  }) = _DeleteTaskFailure;
  const factory TaskState.fetchAttachedNotesLoading() =
      _FetchAttachedNotesLoading;
  const factory TaskState.fetchAttachedNotesSuccess({
    required List<Note> notes,
  }) = _FetchAttachedNotesSuccess;
  const factory TaskState.fetchAttachedNotesFailure({
    required NetworkExceptions error,
  }) = _FetchAttachedNotesFailure;
  const factory TaskState.fetchAttachedDocumentsLoading() =
      _FetchAttachedDocumentsLoading;
  const factory TaskState.fetchAttachedDocumentsSuccess({
    required List<Document> documents,
  }) = _FetchAttachedDocumentsSuccess;
  const factory TaskState.fetchAttachedDocumentsFailure({
    required NetworkExceptions error,
  }) = _FetchAttachedDocumentsFailure;
  const factory TaskState.removeMemberSuccess() = _RemoveMemberSuccess;
  const factory TaskState.removeMemberFailure({
    required NetworkExceptions error,
  }) = _RemoveMemberFailure;
  const factory TaskState.bottomSheetLoadInProgress() =
      _BottomSheetLoadInProgress;
  const factory TaskState.fetchProjectNotesSuccess({
    required List<Note> notes,
  }) = _FetchProjectNotesSuccess;
  const factory TaskState.fetchProjectNotesFailure({
    required NetworkExceptions error,
  }) = _FetchProjectNotesFailure;
  const factory TaskState.fetchProjectDocumentsSuccess({
    required List<Document> documents,
  }) = _FetchProjectDocumentsSuccess;
  const factory TaskState.fetchProjectDocumentsFailure({
    required NetworkExceptions error,
  }) = _FetchProjectDocumentsFailure;
  const factory TaskState.attachNotesSuccess() = _AttachNotesSuccess;
  const factory TaskState.attachNotesFailure({
    required NetworkExceptions error,
  }) = _AttachNotesFailure;
  const factory TaskState.removeAttachedNoteSuccess() =
      _RemoveAttachedNoteSuccess;
  const factory TaskState.removeAttachedNoteFailure({
    required NetworkExceptions error,
  }) = _RemoveAttachedNoteFailure;
  const factory TaskState.attachDocumentsSuccess() = _AttachDocumentsSuccess;
  const factory TaskState.attachDocumentFailure({
    required NetworkExceptions error,
  }) = _AttachDocumentFailure;
  const factory TaskState.removeAttachedDocumentSuccess() =
      _RemoveAttachedDocumentSuccess;
  const factory TaskState.removeAttachedDocumentFailure({
    required NetworkExceptions error,
  }) = _RemoveAttachedDocumentFailure;
}
