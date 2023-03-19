part of 'login_bloc.dart';

@freezed
class LoginState with _$LoginState {
  const factory LoginState.initial() = _Initial;
  const factory LoginState.loadInProgress() = _LoadInProgress;
  const factory LoginState.loginSuccess({
    required String token,
  }) = _LoginSuccess;
  const factory LoginState.loginFailure({
    required NetworkExceptions error,
  }) = _LoginFailure;
}
