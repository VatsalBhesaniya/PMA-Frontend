part of 'profile_bloc.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState.initial() = _Initial;
  const factory ProfileState.loadInProgress() = _LoadInProgress;
  const factory ProfileState.fetchUserSucceess({
    required User user,
  }) = _FetchUserSucceess;
  const factory ProfileState.fetchUserFailure({
    required NetworkExceptions error,
  }) = _FetchUserFailure;
  const factory ProfileState.updateUserSuccess() = _UpdateUserSuccess;
  const factory ProfileState.updateUserFailure({
    required NetworkExceptions error,
  }) = _UpdateUserFailure;
  const factory ProfileState.deleteUserSuccess() = _DeleteUserSuccess;
  const factory ProfileState.deleteUserFailure({
    required NetworkExceptions error,
  }) = _DeleteUserFailure;
}
