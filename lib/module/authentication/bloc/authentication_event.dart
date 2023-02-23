part of 'authentication_bloc.dart';

@freezed
class AuthenticationEvent with _$AuthenticationEvent {
  const factory AuthenticationEvent.appStarted() = _AppStarted;
  const factory AuthenticationEvent.logout() = _Logout;
}
