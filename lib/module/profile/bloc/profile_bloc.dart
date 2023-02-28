import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/manager/app_storage_manager.dart';
import 'package:pma/models/user.dart';
import 'package:pma/module/app/user_repository.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

part 'profile_state.dart';
part 'profile_event.dart';
part 'profile_bloc.freezed.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required UserRepository userRepository,
    required AppStorageManager appStorageManager,
  })  : _userRepository = userRepository,
        _appStorageManager = appStorageManager,
        super(const ProfileState.initial()) {
    on<_FetchUser>(_onFetchUser);
  }

  final UserRepository _userRepository;
  final AppStorageManager _appStorageManager;

  FutureOr<void> _onFetchUser(
      _FetchUser event, Emitter<ProfileState> emit) async {
    final String? token = await _appStorageManager.getUserTokenString();
    if (token == null) {
      emit(
        const ProfileState.fetchUserFailure(
          error: NetworkExceptions.defaultError(),
        ),
      );
    } else {
      final ApiResult<User> apiResult =
          await _userRepository.fetchCurrentUser(token: token);
      apiResult.when(
        success: (User user) {
          emit(
            ProfileState.fetchUserSucceess(user: user),
          );
        },
        failure: (NetworkExceptions error) {
          emit(
            ProfileState.fetchUserFailure(error: error),
          );
        },
      );
    }
  }
}
