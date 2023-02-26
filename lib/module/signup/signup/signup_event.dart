part of 'signup_bloc.dart';

@freezed
class SignupEvent with _$SignupEvent {
  const factory SignupEvent.signupSubmitted({
    required CreateUser user,
  }) = _SignupSubmitted;
}
