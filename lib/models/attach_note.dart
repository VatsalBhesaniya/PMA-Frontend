import 'package:freezed_annotation/freezed_annotation.dart';
part 'attach_note.freezed.dart';
part 'attach_note.g.dart';

@freezed
class AttachNote with _$AttachNote {
  @JsonSerializable(explicitToJson: true)
  factory AttachNote({
    @JsonKey(name: 'task_id') required int taskId,
    @JsonKey(name: 'note_id') required int noteId,
  }) = _AttachNotes;

  factory AttachNote.fromJson(Map<String, dynamic> json) =>
      _$AttachNoteFromJson(json);
}
