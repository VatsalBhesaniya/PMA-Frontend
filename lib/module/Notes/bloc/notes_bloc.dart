import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/note.dart';
import 'package:pma/module/Notes/notes_repository.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

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
    final ApiResult<List<Note>?> apiResult =
        await _notesRepository.fetchNotes();
    apiResult.when(
      success: (List<Note>? notes) {
        if (notes == null) {
          emit(const _FetchNotesFailure());
        } else {
          emit(_FetchNotesSuccess(notes: notes));
        }
      },
      failure: (NetworkExceptions error) {
        emit(const _FetchNotesFailure());
      },
    );
  }
}
