part of 'authentication_bloc.dart';

@freezed
class AuthenticationState with _$AuthenticationState {
  const factory AuthenticationState.initial() = _Initial;
  const factory AuthenticationState.loadInProgress() = _LoadInProgress;
  const factory AuthenticationState.authenticated({
    required String token,
    required User user,
  }) = _Authenticated;
  const factory AuthenticationState.unauthenticated() = _Unauthenticated;
}
