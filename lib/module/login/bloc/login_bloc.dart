import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:pma/module/app/user_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(const LoginState.unauthenticated()) {
    on<LoginSubmitted>(_onlogin);
  }

  final UserRepository _userRepository;

  FutureOr<void> _onlogin(
      LoginSubmitted event, Emitter<LoginState> emit) async {
    final String? token = await _userRepository.login(
        email: event.email, password: event.password);
    if (token != null) {
      _userRepository.persistToken(token);
      emit(const LoginState.authenticated());
    } else {
      emit(const LoginState.unauthenticated());
    }
  }
}
