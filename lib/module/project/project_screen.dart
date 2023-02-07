import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pma/models/project.dart';
import 'package:pma/module/Documents/bloc/documents_bloc.dart';
import 'package:pma/module/Documents/documents_repository.dart';
import 'package:pma/module/Notes/bloc/notes_bloc.dart';
import 'package:pma/module/Notes/notes_repository.dart';
import 'package:pma/module/Notes/notes_screen.dart';
import 'package:pma/module/documents/documents_screen.dart';
import 'package:pma/module/project/bloc/project_bloc.dart';
import 'package:pma/module/project/project_repository.dart';
import 'package:pma/module/tasks/bloc/tasks_bloc.dart';
import 'package:pma/module/tasks/tasks_repository.dart';
import 'package:pma/module/tasks/tasks_screen.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({
    required this.projectId,
    super.key,
  });

  final String projectId;

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProjectBloc>(
      create: (BuildContext context) => ProjectBloc(
        projectRepository: ProjectRepository(),
      ),
      child: BlocBuilder<ProjectBloc, ProjectState>(
        builder: (BuildContext context, ProjectState state) {
          return state.when(
            initial: () {
              context.read<ProjectBloc>().add(
                    ProjectEvent.fetchProject(
                      projectId: int.parse(widget.projectId),
                    ),
                  );
              return const CircularProgressIndicator();
            },
            loadInProgress: () {
              return const CircularProgressIndicator();
            },
            fetchProjectSuccess: (Project project) {
              return DefaultTabController(
                length: 3,
                child: Scaffold(
                  appBar: AppBar(
                    title: Text(project.title),
                    bottom: const TabBar(
                      tabs: <Tab>[
                        Tab(text: 'Tasks'),
                        Tab(text: 'Notes'),
                        Tab(text: 'Documents'),
                      ],
                    ),
                  ),
                  body: TabBarView(
                    children: <Widget>[
                      BlocProvider<TasksBloc>(
                        create: (BuildContext context) => TasksBloc(
                          tasksRepository: TasksRepository(),
                        ),
                        child: const TasksScreen(),
                      ),
                      BlocProvider<NotesBloc>(
                        create: (BuildContext context) => NotesBloc(
                          notesRepository: NotesRepository(),
                        ),
                        child: const NotesScreen(),
                      ),
                      BlocProvider<DocumentsBloc>(
                        create: (BuildContext context) => DocumentsBloc(
                          documentsRepository: DocumentsRepository(),
                        ),
                        child: const DocumentsScreen(),
                      ),
                    ],
                  ),
                ),
              );
            },
            fetchProjectFailure: () {
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
