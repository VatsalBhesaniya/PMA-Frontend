import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/invite_member.dart';
import 'package:pma/models/search_user.dart';
import 'package:pma/module/task/task_repository.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

part 'assign_task_state.dart';
part 'assign_task_event.dart';
part 'assign_task_bloc.freezed.dart';

class AssignTaskBloc extends Bloc<AssignTaskEvent, AssignTaskState> {
  AssignTaskBloc({
    required TaskRepository taskRepository,
  })  : _taskRepository = taskRepository,
        super(const AssignTaskState.initial()) {
    on<_AssignMember>(_onAssignMember);
  }

  final TaskRepository _taskRepository;

  FutureOr<void> _onAssignMember(
      _AssignMember event, Emitter<AssignTaskState> emit) async {
    emit(const _LoadInProgress());
    final List<Map<String, dynamic>> members = <Map<String, dynamic>>[];
    for (final SearchUser user in event.users) {
      final InviteMember member = InviteMember(
        userId: user.id,
        projectId: event.projectId,
        role: 3,
        status: 2,
      );
      members.add(member.toJson());
    }
    final ApiResult<void> apiResult = await _taskRepository.assignTaskToMembers(
      taskId: event.taskId,
      membersData: members,
    );
    apiResult.when(
      success: (void value) {
        emit(
          const AssignTaskState.assignTaskToMemberSuccess(),
        );
      },
      failure: (NetworkExceptions error) {
        emit(
          AssignTaskState.assignTaskToMemberFailure(error: error),
        );
      },
    );
  }
}
