import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pma/config/http_client_config.dart';
import 'package:pma/models/search_user.dart';
import 'package:pma/module/assign_task/bloc/assign_task_bloc.dart';
import 'package:pma/module/select_members/select_members_screen.dart';
import 'package:pma/module/task/task_repository.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';
import 'package:pma/widgets/pma_alert_dialog.dart';

class AssignTaskScreen extends StatefulWidget {
  const AssignTaskScreen({
    super.key,
    required this.taskId,
    required this.projectId,
  });

  final String taskId;
  final String projectId;

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Members'),
      ),
      body: SafeArea(
        child: BlocProvider<AssignTaskBloc>(
          create: (BuildContext context) => AssignTaskBloc(
            taskRepository: TaskRepository(
              dioClient: context.read<DioClient>(),
              httpClient: context.read<HttpClientConfig>(),
            ),
          ),
          child: BlocConsumer<AssignTaskBloc, AssignTaskState>(
            listener: (BuildContext context, AssignTaskState state) {
              state.maybeWhen(
                assignTaskToMemberSuccess: () {
                  context.pop();
                },
                assignTaskToMemberFailure: (NetworkExceptions error) {
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
            buildWhen: (AssignTaskState previous, AssignTaskState current) {
              return current.maybeWhen(
                assignTaskToMemberSuccess: () => false,
                assignTaskToMemberFailure: (NetworkExceptions error) => false,
                orElse: () => true,
              );
            },
            builder: (BuildContext context, AssignTaskState state) {
              return state.maybeWhen(
                initial: () {
                  return Column(
                    children: <Widget>[
                      Expanded(
                        child: SelectMembersScreen(
                          projectId: int.parse(widget.projectId),
                          taskId: int.parse(widget.taskId),
                          buttonText: 'Select',
                          onSelectUsers: (List<SearchUser> users) {
                            context.read<AssignTaskBloc>().add(
                                  AssignTaskEvent.assignTaskToMember(
                                    taskId: int.parse(widget.taskId),
                                    projectId: int.parse(widget.projectId),
                                    users: users
                                        .where((SearchUser user) =>
                                            user.isSelected == true)
                                        .toList(),
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
