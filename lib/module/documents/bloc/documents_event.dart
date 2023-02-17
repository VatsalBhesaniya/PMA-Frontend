part of 'documents_bloc.dart';

@freezed
class DocumentsEvent with _$DocumentsEvent {
  const factory DocumentsEvent.fetchDocuments() = _FetchDocuments;
  const factory DocumentsEvent.deleteDocument({
    required int documentId,
  }) = _DeleteDocument;
}
