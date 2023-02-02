part of 'note_bloc.dart';

@freezed
class NoteEvent with _$NoteEvent {
  const factory NoteEvent.fetchNote({
    required int noteId,
  }) = _FetchNote;
}
