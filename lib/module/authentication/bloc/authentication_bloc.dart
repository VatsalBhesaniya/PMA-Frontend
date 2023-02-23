import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/module/app/user_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';
part 'authentication_bloc.freezed.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(const _Unknown()) {
    on<_AppStarted>(_onAppStarted);
    on<_Logout>(_onLogout);
  }

  final UserRepository _userRepository;

  Future<void> _onAppStarted(
      _AppStarted event, Emitter<AuthenticationState> emit) async {
    emit(const _LoadInProgress());
    final bool hasToken = await _userRepository.hasToken();
    if (hasToken) {
      emit(const _Authenticated());
    } else {
      emit(const _Unauthenticated());
    }
  }

  void _onLogout(_Logout event, Emitter<AuthenticationState> emit) {
    emit(const _LoadInProgress());
    _userRepository.deleteToken();
    emit(const _Unauthenticated());
  }
}
