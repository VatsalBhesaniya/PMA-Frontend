
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  @JsonSerializable(explicitToJson: true)
  factory User({
     @JsonKey() required int id,
    @JsonKey() required String email,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _User;
	
  factory User.fromJson(Map<String, dynamic> json) =>
			_$UserFromJson(json);
}
