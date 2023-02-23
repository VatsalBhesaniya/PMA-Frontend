import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/invite_member.dart';
import 'package:pma/models/search_user.dart';
import 'package:pma/module/invite_members/invite_members_repository.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

part 'invite_members_state.dart';
part 'invite_members_event.dart';
part 'invite_members_bloc.freezed.dart';

class InviteMembersBloc extends Bloc<InviteMembersEvent, InviteMembersState> {
  InviteMembersBloc({
    required InviteMembersRepository inviteMembersRepository,
  })  : _inviteMembersRepository = inviteMembersRepository,
        super(const InviteMembersState.initial()) {
    on<_InviteMembers>(_onInviteMembers);
  }

  final InviteMembersRepository _inviteMembersRepository;

  FutureOr<void> _onInviteMembers(
      _InviteMembers event, Emitter<InviteMembersState> emit) async {
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
    final ApiResult<bool> apiResult =
        await _inviteMembersRepository.inviteMembers(
      membersData: members,
    );
    apiResult.when(
      success: (bool isInvited) {
        if (isInvited) {
          emit(const InviteMembersState.inviteMembersSuccess());
        } else {
          emit(
            const InviteMembersState.inviteMembersFailure(
              error: NetworkExceptions.defaultError(),
            ),
          );
        }
      },
      failure: (NetworkExceptions error) {
        emit(InviteMembersState.inviteMembersFailure(error: error));
      },
    );
  }
}