import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/models/task.dart';
import 'package:pma/module/tasks/bloc/tasks_bloc.dart';
import 'package:pma/utils/network_exceptions.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({
    required this.projectId,
    super.key,
  });

  final String projectId;

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
            _showSnackBar(context: context, theme: theme);
          },
          deleteTaskFailure: (NetworkExceptions error) {
            _buildDeleteTaskFailureAlert(
              context: context,
              theme: theme,
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
            return ListView.builder(
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
                  title: Text(task.title),
                  trailing: IconButton(
                    onPressed: () {
                      _showDeleteTaskConfirmDialog(
                        context: context,
                        theme: theme,
                        taskId: task.id,
                      );
                    },
                    icon: const Icon(
                      Icons.delete_rounded,
                    ),
                  ),
                );
              },
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

  void _showSnackBar({
    required BuildContext context,
    required ThemeData theme,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: const EdgeInsets.all(16),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: theme.colorScheme.surface,
        content: Text(
          'Task successfully deleted',
          textAlign: TextAlign.center,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  void _buildDeleteTaskFailureAlert({
    required BuildContext context,
    required ThemeData theme,
  }) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Alert',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
          content: const Text(
            'Could not delete a task successfully. Please try again.',
          ),
          actions: <Widget>[
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: Text(
                  'OK',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ],
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
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
