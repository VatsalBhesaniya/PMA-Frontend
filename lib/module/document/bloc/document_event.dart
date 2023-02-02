part of 'document_bloc.dart';

@freezed
class DocumentEvent with _$DocumentEvent {
  const factory DocumentEvent.fetchDocument({
    required int documentId,
  }) = _FetchDocument;
}
