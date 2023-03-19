import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/member.dart';
part 'project_detail.freezed.dart';
part 'project_detail.g.dart';

@freezed
class ProjectDetail with _$ProjectDetail {
  @JsonSerializable(explicitToJson: true)
  factory ProjectDetail({
    @JsonKey() required int id,
    @JsonKey() required String title,
    @JsonKey(name: 'created_by') required int createdBy,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey() required List<Member> members,
    @JsonKey(ignore: true) @Default(false) bool isEdit,
    @JsonKey(name: 'current_user_role') @Default(4) int currentUserRole,
  }) = _ProjectDetail;

  factory ProjectDetail.fromJson(Map<String, dynamic> json) =>
      _$ProjectDetailFromJson(json);
}
