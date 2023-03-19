import 'package:freezed_annotation/freezed_annotation.dart';
part 'attach_document.freezed.dart';
part 'attach_document.g.dart';

@freezed
class AttachDocument with _$AttachDocument {
  @JsonSerializable(explicitToJson: true)
  factory AttachDocument({
    @JsonKey(name: 'task_id') required int taskId,
    @JsonKey(name: 'document_id') required int documentId,
  }) = _AttachDocument;

  factory AttachDocument.fromJson(Map<String, dynamic> json) =>
      _$AttachDocumentFromJson(json);
}
