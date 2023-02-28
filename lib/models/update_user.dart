// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_user.freezed.dart';
part 'update_user.g.dart';

@freezed
class UpdateUser with _$UpdateUser {
  @JsonSerializable(explicitToJson: true)
  factory UpdateUser({
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
    @JsonKey() required String username,
    @JsonKey() required String email,
  }) = _UpdateUser;

  factory UpdateUser.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserFromJson(json);
}
