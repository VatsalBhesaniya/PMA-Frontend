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
}
