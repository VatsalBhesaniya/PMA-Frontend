// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'milestone.freezed.dart';
part 'milestone.g.dart';

@freezed
class Milestone with _$Milestone {
  @JsonSerializable(explicitToJson: true)
  factory Milestone({
    @JsonKey() required int id,
    @JsonKey(name: 'project_id') required int projectId,
    @JsonKey() required String title,
    @JsonKey() required List<dynamic>? description,
    @JsonKey(name: 'description_plain_text')
        required String? descriptionPlainText,
    @JsonKey(name: 'is_completed') required bool isCompleted,
    @JsonKey(name: 'completion_date') required String completionDate,
  }) = _Milestone;

  factory Milestone.fromJson(Map<String, dynamic> json) =>
      _$MilestoneFromJson(json);
}
