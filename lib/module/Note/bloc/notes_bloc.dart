import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/note.dart';
import 'package:pma/module/Note/notes_repository.dart';

part 'notes_state.dart';
part 'notes_event.dart';
part 'notes_bloc.freezed.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  NotesBloc({
    required NotesRepository notesRepository,
  })  : _notesRepository = notesRepository,
        super(const NotesState.initial()) {
    on<_FetchNotes>(_onFetchNotes);
  }

  final NotesRepository _notesRepository;

  FutureOr<void> _onFetchNotes(
      _FetchNotes event, Emitter<NotesState> emit) async {
    emit(const _LoadInProgress());
    final List<Note>? result = await _notesRepository.fetchNotes();
    if (result == null) {
      emit(const _FetchNotesFailure());
    } else {
      emit(_FetchNotesSuccess(notes: result));
    }
  }
}
