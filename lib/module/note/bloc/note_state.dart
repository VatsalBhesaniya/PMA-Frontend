part of 'note_bloc.dart';

@freezed
class NoteState with _$NoteState {
  const factory NoteState.initial() = _Initial;
  const factory NoteState.loadInProgress() = _LoadInProgress;
  const factory NoteState.fetchNoteSuccess({
    required Note note,
  }) = _FetchNoteSuccess;
  const factory NoteState.fetchNoteFailure() = _FetchNoteFailure;
  const factory NoteState.updateNoteFailure() = _UpdateNoteFailure;
}
