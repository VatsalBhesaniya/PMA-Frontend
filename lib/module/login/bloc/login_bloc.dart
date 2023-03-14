import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/module/app/user_repository.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

part 'login_event.dart';
part 'login_state.dart';
part 'login_bloc.freezed.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(const LoginState.initial()) {
    on<_LoginSubmitted>(_onlogin);
  }

  final UserRepository _userRepository;

  FutureOr<void> _onlogin(
      _LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(const LoginState.loadInProgress());
    final ApiResult<String?> apiResult = await _userRepository.login(
        email: event.email, password: event.password);
    apiResult.when(
      success: (String? token) {
        if (token != null) {
          _userRepository.persistToken(token);
          emit(const LoginState.loginSuccess());
        } else {
          emit(
            const LoginState.loginFailure(
              error: NetworkExceptions.defaultError(),
            ),
          );
        }
      },
      failure: (NetworkExceptions error) {
        emit(LoginState.loginFailure(error: error));
      },
    );
  }
}
