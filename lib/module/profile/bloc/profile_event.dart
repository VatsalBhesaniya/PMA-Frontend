part of 'profile_bloc.dart';

@freezed
class ProfileEvent with _$ProfileEvent {
  const factory ProfileEvent.fetchUser({
    required int userId,
  }) = _FetchUser;
  const factory ProfileEvent.editProfile({
    required User user,
  }) = _EditProfile;
  const factory ProfileEvent.updateProfile({
    required int userId,
    required UpdateUser user,
  }) = _UpdateProfile;
  const factory ProfileEvent.deleteProfile({
    required int userId,
  }) = _DeleteProfile;
}
