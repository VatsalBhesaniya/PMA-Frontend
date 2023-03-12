// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/milestone.dart';

part 'roadmap.freezed.dart';
part 'roadmap.g.dart';

@freezed
class Roadmap with _$Roadmap {
  @JsonSerializable(explicitToJson: true)
  factory Roadmap({
    @JsonKey() required List<Milestone> milestones,
    @JsonKey(name: 'current_user_role') required int currentUserRole,
  }) = _Roadmap;

  factory Roadmap.fromJson(Map<String, dynamic> json) =>
      _$RoadmapFromJson(json);
}
