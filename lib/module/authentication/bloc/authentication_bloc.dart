import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/user.dart';
import 'package:pma/module/app/user_repository.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';
part 'authentication_bloc.freezed.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(const _Initial()) {
    on<_AppStarted>(_onAppStarted);
    on<_Logout>(_onLogout);
  }

  final UserRepository _userRepository;

  Future<void> _onAppStarted(
      _AppStarted event, Emitter<AuthenticationState> emit) async {
    emit(const _LoadInProgress());
    final String? token = event.token;
    final String? tokenString = event.tokenString;
    if (token != null && tokenString != null) {
      final ApiResult<User> apiResult =
          await _userRepository.fetchCurrentUser(token: tokenString);
      apiResult.when(
        success: (User user) {
          emit(_Authenticated(
            token: token,
            user: user,
          ));
        },
        failure: (NetworkExceptions error) {
          emit(const _Unauthenticated());
        },
      );
    } else {
      emit(const _Unauthenticated());
    }
  }

  void _onLogout(_Logout event, Emitter<AuthenticationState> emit) {
    emit(const _Unauthenticated());
  }
}
