part of 'note_bloc.dart';

@freezed
class NoteEvent with _$NoteEvent {
  const factory NoteEvent.fetchNote({
    required int noteId,
  }) = _FetchNote;
  const factory NoteEvent.editNote({
    required Note note,
  }) = _EditNote;
  const factory NoteEvent.updateNote({
    required Note note,
  }) = _UpdateNote;
}
