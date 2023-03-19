import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/user.dart';
part 'note.freezed.dart';
part 'note.g.dart';

@freezed
class Note with _$Note {
  @JsonSerializable(explicitToJson: true)
  factory Note({
    @JsonKey() required int id,
    @JsonKey(name: 'project_id') required int projectId,
    @JsonKey() required String title,
    @JsonKey() List<dynamic>? content,
    @JsonKey(name: 'content_plain_text') String? contentPlainText,
    @JsonKey(name: 'created_by') int? createdBy,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'last_updated_by') int? lastUpdatedBy,
    @JsonKey(name: 'last_updated_by_user') User? lastUpdatedByUser,
    @JsonKey(name: 'current_user_role') @Default(4) int currentUserRole,
    @JsonKey(ignore: true) @Default(false) bool isExpanded,
    @JsonKey(ignore: true) @Default(false) bool isEdit,
    @JsonKey(ignore: true) @Default(false) bool isSelected,
  }) = _Note;

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
}
