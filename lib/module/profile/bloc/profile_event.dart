part of 'profile_bloc.dart';

@freezed
class ProfileEvent with _$ProfileEvent {
  const factory ProfileEvent.fetchUser({
    required int userId,
  }) = _FetchUser;
}
