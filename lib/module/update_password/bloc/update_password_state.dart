part of 'update_password_bloc.dart';

@freezed
class UpdatePasswordState with _$UpdatePasswordState {
  const factory UpdatePasswordState.initial() = _Initial;
  const factory UpdatePasswordState.loadInProgress() = _LoadInProgress;
  const factory UpdatePasswordState.updatePasswordSuccess() =
      _UpdatePasswordSuccess;
  const factory UpdatePasswordState.updatePasswordFailure({
    required NetworkExceptions error,
  }) = _UpdatePasswordFailure;
}
