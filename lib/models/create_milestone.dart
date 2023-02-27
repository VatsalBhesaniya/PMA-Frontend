// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_milestone.freezed.dart';
part 'create_milestone.g.dart';

@freezed
class CreateMilestone with _$CreateMilestone {
  @JsonSerializable(explicitToJson: true)
  factory CreateMilestone({
    @JsonKey() required int projectId,
    @JsonKey() required String title,
    @JsonKey() required String description,
    @JsonKey() required String isCompleted,
    @JsonKey() required String completionDate,
  }) = _CreateMilestone;

  factory CreateMilestone.fromJson(Map<String, dynamic> json) =>
      _$CreateMilestoneFromJson(json);
}
