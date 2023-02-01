part of 'authentication_bloc.dart';

@immutable
class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => <Object>[];
}

class AuthenticationLoading extends AuthenticationState {
  @override
  List<Object> get props => <Object>[];
}

class Unauthenticated extends AuthenticationState {
  const Unauthenticated();

  @override
  List<Object> get props => <Object>[];
}

class Authenticated extends AuthenticationState {
  const Authenticated();

  @override
  List<Object> get props => <Object>[];
}

class Unknown extends AuthenticationState {
  const Unknown();

  @override
  List<Object> get props => <Object>[];
}
