part of 'notes_bloc.dart';

@freezed
class NotesEvent with _$NotesEvent {
  const factory NotesEvent.fetchNotes() = _FetchNotes;
  const factory NotesEvent.deleteNote({
    required int noteId,
  }) = _DeleteNote;
}
