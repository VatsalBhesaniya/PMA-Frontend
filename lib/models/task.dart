// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/user.dart';

part 'task.freezed.dart';
part 'task.g.dart';

@freezed
class Task with _$Task {
  @JsonSerializable(explicitToJson: true)
  factory Task({
    @JsonKey() required int id,
    @JsonKey(name: 'project_id') required int projectId,
    @JsonKey() required String title,
    @JsonKey() List<dynamic>? description,
    @JsonKey(name: 'description_plain_text') String? descriptionPlainText,
    @JsonKey(name: 'created_by') int? createdBy,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'last_updated_by') int? lastUpdatedBy,
    @JsonKey() required List<int> members,
    @JsonKey() required List<int> notes,
    @JsonKey() required List<int> documents,
    @JsonKey() required int status,
    @JsonKey() required User owner,
    @JsonKey(ignore: true) @Default(false) bool isEdit,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}
