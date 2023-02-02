part of 'document_bloc.dart';

@freezed
class DocumentState with _$DocumentState {
  const factory DocumentState.initial() = _Initial;
  const factory DocumentState.loadInProgress() = _LoadInProgress;
  const factory DocumentState.fetchDocumentSuccess({
    required Document document,
  }) = _FetchDocumentSuccess;
  const factory DocumentState.fetchDocumentFailure() = _FetchDocumentFailure;
}
