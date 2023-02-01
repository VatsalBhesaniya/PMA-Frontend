import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/document.dart';
import 'package:pma/module/Document/documents_repository.dart';

part 'documents_state.dart';
part 'documents_event.dart';
part 'documents_bloc.freezed.dart';

class DocumentsBloc extends Bloc<DocumentsEvent, DocumentsState> {
  DocumentsBloc({
    required DocumentsRepository documentsRepository,
  })  : _documentsRepository = documentsRepository,
        super(const DocumentsState.initial()) {
    on<_FetchDocuments>(_onFetchNotes);
  }

  final DocumentsRepository _documentsRepository;

  FutureOr<void> _onFetchNotes(
      _FetchDocuments event, Emitter<DocumentsState> emit) async {
    emit(const _LoadInProgress());
    final List<Document>? result = await _documentsRepository.fetchDocuments();
    if (result == null) {
      emit(const _FetchDocumentsFailure());
    } else {
      emit(_FetchDocumentsSuccess(documents: result));
    }
  }
}
