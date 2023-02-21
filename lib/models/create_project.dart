// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_project.freezed.dart';
part 'create_project.g.dart';

@freezed
class CreateProject with _$CreateProject {
  @JsonSerializable(explicitToJson: true)
  factory CreateProject({
    @JsonKey() required String title,
  }) = _CreateProject;

  factory CreateProject.fromJson(Map<String, dynamic> json) =>
      _$CreateProjectFromJson(json);
}
