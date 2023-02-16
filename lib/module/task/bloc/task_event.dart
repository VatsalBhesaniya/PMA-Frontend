part of 'task_bloc.dart';

@freezed
class TaskEvent with _$TaskEvent {
  const factory TaskEvent.fetchTask({
    required int taskId,
  }) = _FetchTask;
  const factory TaskEvent.editTask({
    required Task task,
  }) = _EditTask;
  const factory TaskEvent.updateTask({
    required Task task,
  }) = _UpdateTask;
  const factory TaskEvent.fetchAttachedNotes({
    required List<int> noteIds,
  }) = _FetchAttachedNotes;
  const factory TaskEvent.expandTask({
    required List<Note> notes,
  }) = _ExpandTask;
  const factory TaskEvent.fetchAttachedDocuments({
    required List<int> documentIds,
  }) = _FetchAttachedDocuments;
  const factory TaskEvent.expandDocument({
    required List<Document> documents,
  }) = _ExpandDocument;
}
