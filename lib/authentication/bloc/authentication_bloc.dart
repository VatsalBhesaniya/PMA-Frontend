import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:pma/app/user_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(const Unknown()) {
    on<AppStarted>(_onAppStarted);
    on<Logout>(_onLogout);
  }

  final UserRepository _userRepository;

  Future<void> _onAppStarted(
      AppStarted event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    final bool hasToken = await _userRepository.hasToken();
    if (hasToken) {
      emit(const Authenticated());
    } else {
      emit(const Unauthenticated());
    }
  }

  void _onLogout(Logout event, Emitter<AuthenticationState> emit) {
    emit(AuthenticationLoading());
    _userRepository.deleteToken();
    emit(const Unauthenticated());
  }
}
