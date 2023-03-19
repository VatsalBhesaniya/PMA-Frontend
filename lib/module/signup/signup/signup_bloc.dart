
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/create_user.dart';
import 'package:pma/module/app/user_repository.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

part 'signup_state.dart';
part 'signup_event.dart';
part 'signup_bloc.freezed.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  SignupBloc({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(const SignupState.initial()) {
    on<_SignupSubmitted>(_onSignup);
  }
  final UserRepository _userRepository;

  FutureOr<void> _onSignup(
      _SignupSubmitted event, Emitter<SignupState> emit) async {
    emit(const SignupState.loadInProgress());
    final ApiResult<void> apiResult = await _userRepository.signup(
      userJson: event.user.toJson(),
    );
    apiResult.when(
      success: (void result) {
        emit(
          SignupState.signupSuccess(user: event.user),
        );
      },
      failure: (NetworkExceptions error) {
        emit(SignupState.signupFailure(error: error));
      },
    );
  }
}
