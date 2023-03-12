part of 'update_password_bloc.dart';

@freezed
class UpdatePasswordEvent with _$UpdatePasswordEvent {
  const factory UpdatePasswordEvent.updatePassword({
    required UpdatePassword updatePassword,
  }) = _UpdatePassword;
}
