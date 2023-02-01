// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'note.freezed.dart';
part 'note.g.dart';

@freezed
class Note with _$Note {
  @JsonSerializable(explicitToJson: true)
  factory Note({
    @JsonKey() required int id,
    @JsonKey() required String title,
    @JsonKey() String? description,
    @JsonKey(name: 'created_by') int? createdBy,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'last_updated_by') int? lastUpdatedBy,
  }) = _Note;

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
}
