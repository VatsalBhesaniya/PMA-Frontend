part of 'notes_bloc.dart';

@freezed
class NotesState with _$NotesState {
  const factory NotesState.initial() = _Initial;
  const factory NotesState.loadInProgress() = _LoadInProgress;
  const factory NotesState.fetchNotesSuccess({
    required List<Note> notes,
  }) = _FetchNotesSuccess;
  const factory NotesState.fetchNotesFailure({
    required NetworkExceptions error,
  }) = _FetchNotesFailure;
  const factory NotesState.deleteNoteSuccess() = _DeleteNoteSuccess;
  const factory NotesState.deleteNoteFailure({
    required NetworkExceptions error,
  }) = _DeleteNoteFailure;
}
