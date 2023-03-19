import 'package:freezed_annotation/freezed_annotation.dart';
part 'search_user.freezed.dart';
part 'search_user.g.dart';

@freezed
class SearchUser with _$SearchUser {
  @JsonSerializable(explicitToJson: true)
  factory SearchUser({
    @JsonKey() required int id,
    @JsonKey() required String username,
    @JsonKey() required String email,
    @JsonKey(ignore: true) @Default(false) bool isSelected,
  }) = _SearchUser;

  factory SearchUser.fromJson(Map<String, dynamic> json) =>
      _$SearchUserFromJson(json);
}
