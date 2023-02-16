// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_note.freezed.dart';
part 'create_note.g.dart';

@freezed
class CreateNote with _$CreateNote {
  @JsonSerializable(explicitToJson: true)
  factory CreateNote({
    @JsonKey() required String title,
    @JsonKey() List<dynamic>? content,
    @JsonKey(name: 'content_plain_text') String? contentPlainText,
  }) = _CreateNote;

  factory CreateNote.fromJson(Map<String, dynamic> json) =>
      _$CreateNoteFromJson(json);
}
