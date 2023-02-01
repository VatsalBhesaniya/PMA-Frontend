part of 'notes_bloc.dart';

@freezed
class NotesState with _$NotesState {
  const factory NotesState.initial() = _Initial;
  const factory NotesState.loadInProgress() = _LoadInProgress;
  const factory NotesState.fetchNotesSuccess({
    required List<Note> notes,
  }) = _FetchNotesSuccess;
  const factory NotesState.fetchNotesFailure() = _FetchNotesFailure;
}
