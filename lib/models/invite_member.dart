import 'package:freezed_annotation/freezed_annotation.dart';
part 'invite_member.freezed.dart';
part 'invite_member.g.dart';

@freezed
class InviteMember with _$InviteMember {
  @JsonSerializable(explicitToJson: true)
  factory InviteMember({
    @JsonKey(name: 'user_id') required int userId,
    @JsonKey(name: 'project_id') required int projectId,
    @JsonKey() required int role,
  }) = _InviteMember;

  factory InviteMember.fromJson(Map<String, dynamic> json) =>
      _$InviteMemberFromJson(json);
}
