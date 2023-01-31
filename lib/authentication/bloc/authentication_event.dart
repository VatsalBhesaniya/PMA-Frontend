part of 'authentication_bloc.dart';

@immutable
abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => <Object>[];
}

class AppStarted extends AuthenticationEvent {
  @override
  List<Object> get props => <Object>[];
}

class Logout extends AuthenticationEvent {
  @override
  List<Object> get props => <Object>[];
}
