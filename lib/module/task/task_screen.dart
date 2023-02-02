import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pma/models/task.dart';
import 'package:pma/module/task/bloc/task_bloc.dart';
import 'package:pma/module/task/task_repository.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({
    required this.taskId,
    super.key,
  });

  final String taskId;

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<TaskBloc>(
      create: (BuildContext context) => TaskBloc(
        taskRepository: TaskRepository(),
      ),
      child: BlocBuilder<TaskBloc, TaskState>(
        builder: (BuildContext context, TaskState state) {
          return state.when(
            initial: () {
              context.read<TaskBloc>().add(
                    TaskEvent.fetchTask(
                      taskId: int.parse(widget.taskId),
                    ),
                  );
              return const CircularProgressIndicator();
            },
            loadInProgress: () {
              return const CircularProgressIndicator();
            },
            fetchTaskSuccess: (Task task) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(task.title),
                ),
                body: SafeArea(
                  child: Column(
                    children: <Widget>[
                      const Text('Created At'),
                      Text(task.createdAt),
                    ],
                  ),
                ),
              );
            },
            fetchTaskFailure: () {
              return const Center(
                child: Text('Something went wrong.'),
              );
            },
          );
        },
      ),
    );
  }
}
