import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pma/models/search_user.dart';
import 'package:pma/module/invite_members/bloc/invite_members_bloc.dart';
import 'package:pma/module/invite_members/invite_members_repository.dart';
import 'package:pma/module/select_users/select_users_screen.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';
import 'package:pma/widgets/pma_alert_dialog.dart';

class InviteMembersScreen extends StatefulWidget {
  const InviteMembersScreen({
    super.key,
    required this.projectId,
  });

  final String projectId;

  @override
  State<InviteMembersScreen> createState() => _InviteMembersScreenState();
}

class _InviteMembersScreenState extends State<InviteMembersScreen> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Members'),
      ),
      body: SafeArea(
        child: BlocProvider<InviteMembersBloc>(
          create: (BuildContext context) => InviteMembersBloc(
            inviteMembersRepository: InviteMembersRepository(
              dioClient: context.read<DioClient>(),
            ),
          ),
          child: BlocConsumer<InviteMembersBloc, InviteMembersState>(
            listener: (BuildContext context, InviteMembersState state) {
              state.maybeWhen(
                inviteMembersSuccess: () {
                  context.pop();
                },
                inviteMembersFailure: (NetworkExceptions error) {
                  pmaAlertDialog(
                    context: context,
                    theme: theme,
                    error:
                        'Could not invite members successfully. Please try again.',
                  );
                },
                orElse: () => null,
              );
            },
            buildWhen:
                (InviteMembersState previous, InviteMembersState current) {
              return current.maybeWhen(
                inviteMembersSuccess: () => false,
                inviteMembersFailure: (NetworkExceptions error) => false,
                orElse: () => true,
              );
            },
            builder: (BuildContext context, InviteMembersState state) {
              return state.maybeWhen(
                initial: () {
                  return Column(
                    children: <Widget>[
                      Expanded(
                        child: SelectUsersScreen(
                          projectId: int.parse(widget.projectId),
                          buttonText: 'Invite',
                          onSelectUsers: (List<SearchUser> users) {
                            context.read<InviteMembersBloc>().add(
                                  InviteMembersEvent.inviteMembers(
                                    users: users
                                        .where((SearchUser user) =>
                                            user.isSelected == true)
                                        .toList(),
                                    projectId: int.parse(widget.projectId),
                                  ),
                                );
                          },
                        ),
                      ),
                    ],
                  );
                },
                loadInProgress: () {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                orElse: () => const SizedBox(),
              );
            },
          ),
        ),
      ),
    );
  }
}
