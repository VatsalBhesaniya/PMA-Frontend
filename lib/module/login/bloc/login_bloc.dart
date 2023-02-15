import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:pma/module/app/user_repository.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

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
    final ApiResult<String?> apiResult = await _userRepository.login(
        email: event.email, password: event.password);
    apiResult.when(
      success: (String? token) {
        if (token != null) {
          _userRepository.persistToken('Bearer $token');
          emit(const LoginState.authenticated());
        } else {
          emit(const LoginState.unauthenticated());
        }
      },
      failure: (NetworkExceptions error) {
        emit(const LoginState.unauthenticated());
      },
    );
  }
}
