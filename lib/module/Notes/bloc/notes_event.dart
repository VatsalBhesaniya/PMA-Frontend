part of 'notes_bloc.dart';

@freezed
class NotesEvent with _$NotesEvent {
  const factory NotesEvent.fetchNotes() = _FetchNotes;
}
