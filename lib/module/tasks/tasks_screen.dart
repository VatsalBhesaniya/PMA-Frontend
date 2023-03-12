import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/extentions/extensions.dart';
import 'package:pma/models/task.dart';
import 'package:pma/module/tasks/bloc/tasks_bloc.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';
import 'package:pma/widgets/pma_alert_dialog.dart';
import 'package:pma/widgets/snackbar.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({
    required this.projectId,
    required this.currentUserRole,
    super.key,
  });

  final String projectId;
  final int currentUserRole;

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return BlocConsumer<TasksBloc, TasksState>(
      listener: (BuildContext context, TasksState state) {
        state.maybeWhen(
          deleteTaskSuccess: () {
            context.read<TasksBloc>().add(
                  TasksEvent.fetchTasks(
                    projectId: int.parse(widget.projectId),
                  ),
                );
            showSnackBar(
              context: context,
              theme: theme,
              message: 'Task successfully deleted',
            );
          },
          deleteTaskFailure: (NetworkExceptions error) {
            pmaAlertDialog(
              context: context,
              theme: theme,
              error: 'Could not delete task successfully. Please try again.',
            );
          },
          orElse: () => null,
        );
      },
      buildWhen: (TasksState previous, TasksState current) {
        return current.maybeWhen(
          deleteTaskSuccess: () => false,
          deleteTaskFailure: (NetworkExceptions error) => false,
          orElse: () => true,
        );
      },
      builder: (BuildContext context, TasksState state) {
        return state.maybeWhen(
          initial: () {
            context.read<TasksBloc>().add(
                  TasksEvent.fetchTasks(
                    projectId: int.parse(widget.projectId),
                  ),
                );
            return const CircularProgressIndicator();
          },
          loadInProgress: () {
            return const CircularProgressIndicator();
          },
          fetchTasksSuccess: (List<Task> tasks) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      TaskStatus.todo.title,
                      style: theme.textTheme.bodyLarge,
                    ),
                    Divider(
                      thickness: 1,
                      color: theme.colorScheme.primary,
                    ),
                    _buildTasks(
                      context: context,
                      tasks: tasks
                          .where((Task task) =>
                              task.status - 1 == TaskStatus.todo.index)
                          .toList(),
                      theme: theme,
                    ),
                    Text(
                      TaskStatus.inProgress.title,
                      style: theme.textTheme.bodyLarge,
                    ),
                    Divider(
                      thickness: 1,
                      color: theme.colorScheme.primary,
                    ),
                    _buildTasks(
                      context: context,
                      tasks: tasks
                          .where((Task task) =>
                              task.status - 1 == TaskStatus.inProgress.index)
                          .toList(),
                      theme: theme,
                    ),
                    Text(
                      TaskStatus.completed.title,
                      style: theme.textTheme.bodyLarge,
                    ),
                    Divider(
                      thickness: 1,
                      color: theme.colorScheme.primary,
                    ),
                    _buildTasks(
                      context: context,
                      tasks: tasks
                          .where((Task task) =>
                              task.status - 1 == TaskStatus.completed.index)
                          .toList(),
                      theme: theme,
                    ),
                    Text(
                      TaskStatus.qa.title,
                      style: theme.textTheme.bodyLarge,
                    ),
                    Divider(
                      thickness: 1,
                      color: theme.colorScheme.primary,
                    ),
                    _buildTasks(
                      context: context,
                      tasks: tasks
                          .where((Task task) =>
                              task.status - 1 == TaskStatus.qa.index)
                          .toList(),
                      theme: theme,
                    ),
                  ],
                ),
              ),
            );
          },
          fetchTasksFailure: () {
            return const Center(
              child: Text('Something went wrong.'),
            );
          },
          orElse: () => const SizedBox(),
        );
      },
    );
  }

  ListView _buildTasks({
    required BuildContext context,
    required List<Task> tasks,
    required ThemeData theme,
  }) {
    tasks.sort(
      (Task a, Task b) => b.createdAt.compareTo(a.createdAt),
    );
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (BuildContext context, int index) {
        return const Divider(
          height: 1,
          indent: 16,
          endIndent: 20,
        );
      },
      itemCount: tasks.length,
      itemBuilder: (BuildContext context, int index) {
        final Task task = tasks[index];
        return ListTile(
          onTap: () {
            context.goNamed(
              RouteConstants.task,
              params: <String, String>{
                'projectId': widget.projectId,
                'taskId': task.id.toString(),
              },
            );
          },
          title: Text(
            task.title,
            style: theme.textTheme.bodyMedium,
          ),
          trailing: widget.currentUserRole == MemberRole.guest.index + 1
              ? null
              : IconButton(
                  onPressed: () {
                    _showDeleteTaskConfirmDialog(
                      context: context,
                      theme: theme,
                      taskId: task.id,
                    );
                  },
                  color: theme.colorScheme.onError,
                  icon: const Icon(
                    Icons.delete_rounded,
                  ),
                ),
        );
      },
    );
  }

  void _showDeleteTaskConfirmDialog({
    required BuildContext context,
    required ThemeData theme,
    required int taskId,
  }) {
    showDialog<String>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Confirm',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
          content: const Text(
            'Are you sure you want to delete this task?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                context.read<TasksBloc>().add(
                      TasksEvent.deleteTask(taskId: taskId),
                    );
                Navigator.pop(ctx);
              },
              child: Text(
                'OK',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
