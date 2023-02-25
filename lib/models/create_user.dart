// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_user.freezed.dart';
part 'create_user.g.dart';

@freezed
class CreateUser with _$CreateUser {
  @JsonSerializable(explicitToJson: true)
  factory CreateUser({
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
    @JsonKey() required String username,
    @JsonKey() required String email,
    @JsonKey() required String password,
  }) = _CreateUser;

  factory CreateUser.fromJson(Map<String, dynamic> json) =>
      _$CreateUserFromJson(json);
}
