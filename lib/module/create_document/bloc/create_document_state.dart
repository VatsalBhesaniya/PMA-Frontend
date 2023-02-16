part of 'create_document_bloc.dart';

@freezed
class CreateDocumentState with _$CreateDocumentState {
  const factory CreateDocumentState.initial() = _Initial;
  const factory CreateDocumentState.loadInProgress() = _LoadInProgress;
  const factory CreateDocumentState.createDocumentSuccess({
    required int documentId,
  }) = _CreateDocumentSuccess;
  const factory CreateDocumentState.createDocumentFailure({
    required NetworkExceptions error,
  }) = _CreateDocumentFailure;
}
