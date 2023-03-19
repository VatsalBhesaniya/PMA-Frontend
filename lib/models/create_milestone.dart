import 'package:freezed_annotation/freezed_annotation.dart';
part 'create_milestone.freezed.dart';
part 'create_milestone.g.dart';

@freezed
class CreateMilestone with _$CreateMilestone {
  @JsonSerializable(explicitToJson: true)
  factory CreateMilestone({
    @JsonKey(name: 'project_id') required int projectId,
    @JsonKey() required String title,
    @JsonKey() required List<dynamic>? description,
    @JsonKey(name: 'description_plain_text')
        required String? descriptionPlainText,
    @JsonKey(name: 'is_completed') required bool isCompleted,
    @JsonKey(name: 'completion_date') required String completionDate,
  }) = _CreateMilestone;

  factory CreateMilestone.fromJson(Map<String, dynamic> json) =>
      _$CreateMilestoneFromJson(json);
}
