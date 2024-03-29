import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/document.dart';
import 'package:pma/module/Documents/documents_repository.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

part 'documents_state.dart';
part 'documents_event.dart';
part 'documents_bloc.freezed.dart';

class DocumentsBloc extends Bloc<DocumentsEvent, DocumentsState> {
  DocumentsBloc({
    required DocumentsRepository documentsRepository,
  })  : _documentsRepository = documentsRepository,
        super(const DocumentsState.initial()) {
    on<_FetchDocuments>(_onFetchDocuments);
    on<_DeleteDocument>(_onDeleteDocument);
  }

  final DocumentsRepository _documentsRepository;

  FutureOr<void> _onFetchDocuments(
      _FetchDocuments event, Emitter<DocumentsState> emit) async {
    emit(const _LoadInProgress());
    final ApiResult<List<Document>> apiResult =
        await _documentsRepository.fetchDocuments(projectId: event.projectId);
    apiResult.when(
      success: (List<Document> documents) {
        emit(_FetchDocumentsSuccess(documents: documents));
      },
      failure: (NetworkExceptions error) {
        emit(_FetchDocumentsFailure(error: error));
      },
    );
  }

  FutureOr<void> _onDeleteDocument(
      _DeleteDocument event, Emitter<DocumentsState> emit) async {
    emit(const _LoadInProgress());
    final ApiResult<void> apiResult = await _documentsRepository.deleteDocument(
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
