// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_document.freezed.dart';
part 'create_document.g.dart';

@freezed
class CreateDocument with _$CreateDocument {
  @JsonSerializable(explicitToJson: true)
  factory CreateDocument({
    @JsonKey(name: 'project_id') required int projectId,
    @JsonKey() required String title,
    @JsonKey() List<dynamic>? content,
    @JsonKey(name: 'content_plain_text') String? contentPlainText,
  }) = _CreateDocument;

  factory CreateDocument.fromJson(Map<String, dynamic> json) =>
      _$CreateDocumentFromJson(json);
}
