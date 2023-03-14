import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/update_password.dart';
import 'package:pma/module/app/user_repository.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

part 'update_password_state.dart';
part 'update_password_event.dart';
part 'update_password_bloc.freezed.dart';

class UpdatePasswordBloc
    extends Bloc<UpdatePasswordEvent, UpdatePasswordState> {
  UpdatePasswordBloc({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(const UpdatePasswordState.initial()) {
    on<_UpdatePassword>(_onUpdatePassword);
  }

  final UserRepository _userRepository;

  FutureOr<void> _onUpdatePassword(
      _UpdatePassword event, Emitter<UpdatePasswordState> emit) async {
    emit(const UpdatePasswordState.loadInProgress());
    final ApiResult<void> apiResult = await _userRepository.updateUserPassword(
      userData: event.updatePassword.toJson(),
    );
    apiResult.when(
      success: (void value) {
        emit(const UpdatePasswordState.updatePasswordSuccess());
      },
      failure: (NetworkExceptions error) {
        emit(UpdatePasswordState.updatePasswordFailure(error: error));
      },
    );
  }
}
