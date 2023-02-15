// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'document.freezed.dart';
part 'document.g.dart';

@freezed
class Document with _$Document {
  @JsonSerializable(explicitToJson: true)
  factory Document({
    @JsonKey() required int id,
    @JsonKey() required String title,
    @JsonKey() List<dynamic>? content,
    @JsonKey(name: 'content_plain_text') String? contentPlainText,
    @JsonKey(name: 'created_by') int? createdBy,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'last_updated_by') int? lastUpdatedBy,
    @JsonKey(ignore: true) @Default(false) bool isExpanded,
    @JsonKey(ignore: true) @Default(false) bool isEdit,
  }) = _Document;

  factory Document.fromJson(Map<String, dynamic> json) =>
      _$DocumentFromJson(json);
}
