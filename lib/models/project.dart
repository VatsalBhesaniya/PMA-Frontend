// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'project.freezed.dart';
part 'project.g.dart';

@freezed
class Project with _$Project {
  @JsonSerializable(explicitToJson: true)
  factory Project({
    @JsonKey() required int id,
    @JsonKey() required String title,
    @JsonKey(name: 'created_by') required int createdBy,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'current_user_role') @Default(4) int currentUserRole,
  }) = _Project;

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);
}
