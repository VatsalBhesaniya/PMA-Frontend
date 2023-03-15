import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
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
    on<_EditDocument>(_onEditDocument);
    on<_UpdateDocument>(_onUpdateDocument);
    on<_DeleteDocument>(_onDeleteDocument);
  }

  final DocumentRepository _documentRepository;

  FutureOr<void> _onFetchDocument(
      _FetchDocument event, Emitter<DocumentState> emit) async {
    emit(const _LoadInProgress());
    final ApiResult<Document> apiResult =
        await _documentRepository.fetchDocument(documentId: event.documentId);
    apiResult.when(
      success: (Document document) {
        emit(_FetchDocumentSuccess(document: document));
      },
      failure: (NetworkExceptions error) {
        emit(const _FetchDocumentFailure());
      },
    );
  }

  void _onEditDocument(_EditDocument event, Emitter<DocumentState> emit) {
    emit(const _LoadInProgress());
    emit(_FetchDocumentSuccess(document: event.document));
  }

  FutureOr<void> _onUpdateDocument(
      _UpdateDocument event, Emitter<DocumentState> emit) async {
    emit(const _LoadInProgress());
    final ApiResult<Document> apiResult =
        await _documentRepository.updateDocument(document: event.document);
    apiResult.when(
      success: (Document document) {
        emit(_FetchDocumentSuccess(document: document));
      },
      failure: (NetworkExceptions error) {
        emit(const _UpdateDocumentFailure());
      },
    );
  }

  FutureOr<void> _onDeleteDocument(
      _DeleteDocument event, Emitter<DocumentState> emit) async {
    emit(const _LoadInProgress());
    final ApiResult<void> apiResult = await _documentRepository.deleteDocument(
      documentId: event.documentId,
    );
    apiResult.when(
      success: (void result) {
        emit(const _DeleteDocumentSuccess());
      },
      failure: (NetworkExceptions error) {
        emit(_DeleteDocumentFailure(error: error));
      },
    );
  }
}
