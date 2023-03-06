import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/manager/app_storage_manager.dart';
import 'package:pma/models/update_user.dart';
import 'package:pma/models/user.dart';
import 'package:pma/module/app/user_repository.dart';
import 'package:pma/module/profile/profile_repository.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

part 'profile_state.dart';
part 'profile_event.dart';
part 'profile_bloc.freezed.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required UserRepository userRepository,
    required ProfileRepository profileRepository,
    required AppStorageManager appStorageManager,
  })  : _userRepository = userRepository,
        _profileRepository = profileRepository,
        _appStorageManager = appStorageManager,
        super(const ProfileState.initial()) {
    on<_FetchUser>(_onFetchUser);
    on<_EditProfile>(_onEditProfile);
    on<_UpdateProfile>(_onUpdateProfile);
    on<_DeleteProfile>(_onDeleteProfile);
  }

  final UserRepository _userRepository;
  final ProfileRepository _profileRepository;
  final AppStorageManager _appStorageManager;

  FutureOr<void> _onFetchUser(
      _FetchUser event, Emitter<ProfileState> emit) async {
    const ProfileState.loadInProgress();
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

  FutureOr<void> _onEditProfile(
      _EditProfile event, Emitter<ProfileState> emit) async {
    const ProfileState.loadInProgress();
    emit(
      ProfileState.fetchUserSucceess(user: event.user),
    );
  }

  FutureOr<void> _onUpdateProfile(
      _UpdateProfile event, Emitter<ProfileState> emit) async {
    const ProfileState.loadInProgress();
    final ApiResult<User> apiResult = await _profileRepository.updateUser(
      userId: event.userId,
      userData: event.user.toJson(),
    );
    apiResult.when(
      success: (User user) {
        emit(
          const ProfileState.updateUserSuccess(),
        );
      },
      failure: (NetworkExceptions error) {
        emit(
          ProfileState.updateUserFailure(error: error),
        );
      },
    );
  }

  FutureOr<void> _onDeleteProfile(
      _DeleteProfile event, Emitter<ProfileState> emit) async {
    const ProfileState.loadInProgress();
    final ApiResult<void> apiResult = await _profileRepository.deleteUser(
      userId: event.userId,
    );
    apiResult.when(
      success: (void value) {
        emit(
          const ProfileState.deleteUserSuccess(),
        );
      },
      failure: (NetworkExceptions error) {
        emit(
          ProfileState.deleteUserFailure(error: error),
        );
      },
    );
  }
}
