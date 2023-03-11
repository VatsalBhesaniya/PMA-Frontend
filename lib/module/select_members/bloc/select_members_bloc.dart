import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/search_user.dart';
import 'package:pma/module/project/project_repository.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

part 'select_members_state.dart';
part 'select_members_event.dart';
part 'select_members_bloc.freezed.dart';

class SelectMembersBloc extends Bloc<SelectMembersEvent, SelectMembersState> {
  SelectMembersBloc({
    required ProjectRepository projectRepository,
  })  : _projectRepository = projectRepository,
        super(const SelectMembersState.initial()) {
    on<_SearchUsers>(_onSearchUsers);
    on<_SelectUser>(_onSelectUser);
  }

  final ProjectRepository _projectRepository;

  FutureOr<void> _onSearchUsers(
      _SearchUsers event, Emitter<SelectMembersState> emit) async {
    emit(const _LoadInProgress());
    final ApiResult<List<SearchUser>> apiResult =
        await _projectRepository.fetchProjectMembers(
      searchText: event.searchText,
      projectId: event.projectId,
      taskId: event.taskId,
    );
    apiResult.when(
      success: (List<SearchUser>? users) {
        if (users == null) {
          emit(
            const SelectMembersState.searchUsersFailure(
              error: NetworkExceptions.defaultError(),
            ),
          );
        } else {
          emit(
            SelectMembersState.searchUsersSuccess(
              users: users,
            ),
          );
        }
      },
      failure: (NetworkExceptions error) {
        emit(
          const SelectMembersState.searchUsersFailure(
            error: NetworkExceptions.defaultError(),
          ),
        );
      },
    );
  }

  void _onSelectUser(_SelectUser event, Emitter<SelectMembersState> emit) {
    emit(const _LoadInProgress());
    final List<SearchUser> users = List<SearchUser>.from(event.users);
    final SearchUser user = users[event.index];
    users[event.index] = user.copyWith(isSelected: !user.isSelected);
    emit(
      SelectMembersState.searchUsersSuccess(
        users: users,
      ),
    );
  }
}
