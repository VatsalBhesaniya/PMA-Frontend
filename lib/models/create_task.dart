// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_task.freezed.dart';
part 'create_task.g.dart';

@freezed
class CreateTask with _$CreateTask {
  @JsonSerializable(explicitToJson: true)
  factory CreateTask({
    @JsonKey(name: 'project_id') required int projectId,
    @JsonKey() required String title,
    @JsonKey() List<dynamic>? description,
    @JsonKey(name: 'description_plain_text') String? descriptionPlainText,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'last_updated_by') String? lastUpdatedBy,
  }) = _CreateTask;

  factory CreateTask.fromJson(Map<String, dynamic> json) =>
      _$CreateTaskFromJson(json);
}
