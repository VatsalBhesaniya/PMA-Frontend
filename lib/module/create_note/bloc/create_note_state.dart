part of 'create_note_bloc.dart';

@freezed
class CreateNoteState with _$CreateNoteState {
  const factory CreateNoteState.initial() = _Initial;
  const factory CreateNoteState.loadInProgress() = _LoadInProgress;
  const factory CreateNoteState.createNoteSuccess({
    required int noteId,
  }) = _CreateNoteSuccess;
  const factory CreateNoteState.createNoteFailure({
    required NetworkExceptions error,
  }) = _CreateNoteFailure;
}
