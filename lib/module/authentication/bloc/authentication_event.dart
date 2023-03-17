part of 'authentication_bloc.dart';

@freezed
class AuthenticationEvent with _$AuthenticationEvent {
  const factory AuthenticationEvent.appStarted({
    required String? token,
    required String? tokenString,
  }) = _AppStarted;
  const factory AuthenticationEvent.logout() = _Logout;
}
