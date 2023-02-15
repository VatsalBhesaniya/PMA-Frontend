import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/document.dart';
import 'package:pma/module/document/document_repository.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

part 'document_state.dart';
part 'document_event.dart';
part 'document_bloc.freezed.dart';

class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  DocumentBloc({
    required DocumentRepository documentRepository,
  })  : _documentRepository = documentRepository,
        super(const DocumentState.initial()) {
    on<_FetchDocument>(_onFetchDocument);
  }

  final DocumentRepository _documentRepository;

  FutureOr<void> _onFetchDocument(
      _FetchDocument event, Emitter<DocumentState> emit) async {
    emit(const _LoadInProgress());
    final ApiResult<Document?> apiResult =
        await _documentRepository.fetchDocument(documentId: event.documentId);
    apiResult.when(
      success: (Document? document) {
        if (document == null) {
          emit(const _FetchDocumentFailure());
        } else {
          emit(_FetchDocumentSuccess(document: document));
        }
      },
      failure: (NetworkExceptions error) {
        emit(const _FetchDocumentFailure());
      },
    );
  }
}
