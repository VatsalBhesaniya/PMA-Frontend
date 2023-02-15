part of 'document_bloc.dart';

@freezed
class DocumentEvent with _$DocumentEvent {
  const factory DocumentEvent.fetchDocument({
    required int documentId,
  }) = _FetchDocument;
  const factory DocumentEvent.editDocument({
    required Document document,
  }) = _EditDocument;
  const factory DocumentEvent.updateDocument({
    required Document document,
  }) = _UpdateDocument;
}
