part of 'signup_bloc.dart';

@freezed
class SignupState with _$SignupState {
  const factory SignupState.initial() = _Initial;
  const factory SignupState.loadInProgress() = _LoadInProgress;
  const factory SignupState.signupSuccess({
    required CreateUser user,
  }) = _SignupSuccess;
  const factory SignupState.signupFailure({
    required NetworkExceptions error,
  }) = _SignupFailure;
}
