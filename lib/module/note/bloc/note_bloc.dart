import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/note.dart';
import 'package:pma/module/note/note_repository.dart';

part 'note_state.dart';
part 'note_event.dart';
part 'note_bloc.freezed.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  NoteBloc({
    required NoteRepository noteRepository,
  })  : _noteRepository = noteRepository,
        super(const NoteState.initial()) {
    on<_FetchNote>(_onFetchNote);
  }

  final NoteRepository _noteRepository;

  FutureOr<void> _onFetchNote(_FetchNote event, Emitter<NoteState> emit) async {
    emit(const _LoadInProgress());
    final Note? result = await _noteRepository.fetchNote(noteId: event.noteId);
    if (result == null) {
      emit(const _FetchNoteFailure());
    } else {
      emit(_FetchNoteSuccess(note: result));
    }
  }
}
