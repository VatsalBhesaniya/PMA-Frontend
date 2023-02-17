part of 'task_bloc.dart';

@freezed
class TaskState with _$TaskState {
  const factory TaskState.initial() = _Initial;
  const factory TaskState.loadInProgress() = _LoadInProgress;
  const factory TaskState.fetchTaskSuccess({
    required Task task,
  }) = _FetchTaskSuccess;
  const factory TaskState.fetchTaskFailure() = _FetchTaskFailure;
  const factory TaskState.updateTaskFailure() = _UpdateTaskFailure;
  const factory TaskState.deleteTaskSuccess() = _DeleteTaskSuccess;
  const factory TaskState.deleteTaskFailure({
    required NetworkExceptions error,
  }) = _DeleteTaskFailure;
  const factory TaskState.fetchAttachedNotesLoading() =
      _FetchAttachedNotesLoading;
  const factory TaskState.fetchAttachedNotesSuccess({
    required List<Note> notes,
  }) = _FetchAttachedNotesSuccess;
  const factory TaskState.fetchAttachedNotesFailure() =
      _FetchAttachedNotesFailure;
  const factory TaskState.fetchAttachedDocumentsLoading() =
      _FetchAttachedDocumentsLoading;
  const factory TaskState.fetchAttachedDocumentsSuccess({
    required List<Document> documents,
  }) = _FetchAttachedDocumentsSuccess;
  const factory TaskState.fetchAttachedDocumentsFailure() =
      _FetchAttachedDocumentsFailure;
}
