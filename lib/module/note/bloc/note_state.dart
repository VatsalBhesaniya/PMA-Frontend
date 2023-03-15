part of 'note_bloc.dart';

@freezed
class NoteState with _$NoteState {
  const factory NoteState.initial() = _Initial;
  const factory NoteState.loadInProgress() = _LoadInProgress;
  const factory NoteState.fetchNoteSuccess({
    required Note note,
  }) = _FetchNoteSuccess;
  const factory NoteState.fetchNoteFailure({
    required NetworkExceptions error,
  }) = _FetchNoteFailure;
  const factory NoteState.updateNoteFailure({
    required NetworkExceptions error,
  }) = _UpdateNoteFailure;
  const factory NoteState.deleteNoteSuccess() = _DeleteNoteSuccess;
  const factory NoteState.deleteNoteFailure({
    required NetworkExceptions error,
  }) = _DeleteNoteFailure;
}
