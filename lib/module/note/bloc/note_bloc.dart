import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/note.dart';
import 'package:pma/module/note/note_repository.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

part 'note_state.dart';
part 'note_event.dart';
part 'note_bloc.freezed.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  NoteBloc({
    required NoteRepository noteRepository,
  })  : _noteRepository = noteRepository,
        super(const NoteState.initial()) {
    on<_FetchNote>(_onFetchNote);
    on<_EditNote>(_onEditNote);
    on<_UpdateNote>(_onUpdateNote);
    on<_DeleteNote>(_onDeleteNote);
  }

  final NoteRepository _noteRepository;

  FutureOr<void> _onFetchNote(_FetchNote event, Emitter<NoteState> emit) async {
    emit(const _LoadInProgress());
    final ApiResult<Note> apiResult =
        await _noteRepository.fetchNote(noteId: event.noteId);
    apiResult.when(
      success: (Note note) {
        emit(_FetchNoteSuccess(note: note));
      },
      failure: (NetworkExceptions error) {
        emit(_FetchNoteFailure(error: error));
      },
    );
  }

  void _onEditNote(_EditNote event, Emitter<NoteState> emit) {
    emit(const _LoadInProgress());
    emit(_FetchNoteSuccess(note: event.note));
  }

  FutureOr<void> _onUpdateNote(
      _UpdateNote event, Emitter<NoteState> emit) async {
    emit(const _LoadInProgress());
    final ApiResult<Note> apiResult =
        await _noteRepository.updateNote(note: event.note);
    apiResult.when(
      success: (Note note) {
        emit(_FetchNoteSuccess(note: note));
      },
      failure: (NetworkExceptions error) {
        emit(_UpdateNoteFailure(error: error));
      },
    );
  }

  FutureOr<void> _onDeleteNote(
      _DeleteNote event, Emitter<NoteState> emit) async {
    emit(const _LoadInProgress());
    final ApiResult<void> apiResult = await _noteRepository.deleteNote(
      noteId: event.noteId,
    );
    apiResult.when(
      success: (void result) {
        emit(const _DeleteNoteSuccess());
      },
      failure: (NetworkExceptions error) {
        emit(_DeleteNoteFailure(error: error));
      },
    );
  }
}
