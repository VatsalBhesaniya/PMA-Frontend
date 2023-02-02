part of 'documents_bloc.dart';

@freezed
class DocumentsState with _$DocumentsState {
  const factory DocumentsState.initial() = _Initial;
  const factory DocumentsState.loadInProgress() = _LoadInProgress;
  const factory DocumentsState.fetchDocumentsSuccess({
    required List<Document> documents,
  }) = _FetchDocumentsSuccess;
  const factory DocumentsState.fetchDocumentsFailure() = _FetchDocumentsFailure;
}
