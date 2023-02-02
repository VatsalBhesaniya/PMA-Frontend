import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/models/task.dart';
import 'package:pma/module/tasks/bloc/tasks_bloc.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksBloc, TasksState>(
      builder: (BuildContext context, TasksState state) {
        return state.when(
          initial: () {
            context.read<TasksBloc>().add(
                  const TasksEvent.fetchTasks(),
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
                        'id': task.id.toString(),
                      },
                    );
                  },
                  title: Text(task.title),
                );
              },
            );
          },
          fetchTasksFailure: () {
            return const Center(
              child: Text('Something went wrong.'),
            );
          },
        );
      },
    );
  }
}
