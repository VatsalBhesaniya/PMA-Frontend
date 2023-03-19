import 'package:freezed_annotation/freezed_annotation.dart';
part 'update_password.freezed.dart';
part 'update_password.g.dart';

@freezed
class UpdatePassword with _$UpdatePassword {
  @JsonSerializable(explicitToJson: true)
  factory UpdatePassword({
    @JsonKey() required String email,
    @JsonKey() required String password,
  }) = _UpdatePassword;

  factory UpdatePassword.fromJson(Map<String, dynamic> json) =>
      _$UpdatePasswordFromJson(json);
}
