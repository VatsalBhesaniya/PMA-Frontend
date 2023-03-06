// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/user.dart';

part 'member.freezed.dart';
part 'member.g.dart';

@freezed
class Member with _$Member {
  @JsonSerializable(explicitToJson: true)
  factory Member({
    @JsonKey(name: 'user_id') required int userId,
    @JsonKey(name: 'project_id') required int projectId,
    @JsonKey() required int role,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey() required User user,
  }) = _Member;

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);
}
