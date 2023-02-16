part of 'create_note_bloc.dart';

@freezed
class CreateNoteEvent with _$CreateNoteEvent {
  const factory CreateNoteEvent.createNote({
    required CreateNote note,
  }) = _CreateNote;
}
