import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/create_note.dart';
import 'package:pma/module/create_note/create_note_repository.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

part 'create_note_state.dart';
part 'create_note_event.dart';
part 'create_note_bloc.freezed.dart';

class CreateNoteBloc extends Bloc<CreateNoteEvent, CreateNoteState> {
  CreateNoteBloc({
    required CreateNoteRepository createNoteRepository,
  })  : _createNoteRepository = createNoteRepository,
        super(const CreateNoteState.initial()) {
    on<_CreateNote>(_onCreateNote);
  }

  final CreateNoteRepository _createNoteRepository;

  FutureOr<void> _onCreateNote(
      _CreateNote event, Emitter<CreateNoteState> emit) async {
    final ApiResult<int> apiResult = await _createNoteRepository.createNote(
      noteData: event.note.toJson(),
    );
    apiResult.when(
      success: (int noteId) {
        emit(
          CreateNoteState.createNoteSuccess(noteId: noteId),
        );
      },
      failure: (NetworkExceptions error) {
        emit(
          const CreateNoteState.createNoteFailure(
            error: NetworkExceptions.defaultError(),
          ),
        );
      },
    );
  }
}
