import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/search_user.dart';
import 'package:pma/module/app/user_repository.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

part 'select_users_state.dart';
part 'select_users_event.dart';
part 'select_users_bloc.freezed.dart';

class SelectUsersBloc extends Bloc<SelectUsersEvent, SelectUsersState> {
  SelectUsersBloc({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(const SelectUsersState.initial()) {
    on<_SearchUsers>(_onSearchUsers);
    on<_SelectUser>(_onSelectUser);
  }

  final UserRepository _userRepository;

  FutureOr<void> _onSearchUsers(
      _SearchUsers event, Emitter<SelectUsersState> emit) async {
    emit(const _LoadInProgress());
    final ApiResult<List<SearchUser>> apiResult = await _userRepository
        .fetchUsers(projectId: event.projectId, searchText: event.searchText);
    apiResult.when(
      success: (List<SearchUser> users) {
        emit(
          SelectUsersState.searchUsersSuccess(
            users: users,
          ),
        );
      },
      failure: (NetworkExceptions error) {
        emit(
          const SelectUsersState.searchUsersFailure(
            error: NetworkExceptions.defaultError(),
          ),
        );
      },
    );
  }

  void _onSelectUser(_SelectUser event, Emitter<SelectUsersState> emit) {
    emit(const _LoadInProgress());
    final List<SearchUser> users = List<SearchUser>.from(event.users);
    final SearchUser user = users[event.index];
    users[event.index] = user.copyWith(isSelected: !user.isSelected);
    emit(
      SelectUsersState.searchUsersSuccess(
        users: users,
      ),
    );
  }
}
