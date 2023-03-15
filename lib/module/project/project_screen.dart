import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router_flow/go_router_flow.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/route_constants.dart';
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

class _ProjectScreenState extends State<ProjectScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return BlocProvider<ProjectBloc>(
      create: (BuildContext context) => ProjectBloc(
        projectRepository: ProjectRepository(
          dio: context.read<Dio>(),
          dioConfig: context.read<DioConfig>(),
        ),
      ),
      child: BlocBuilder<ProjectBloc, ProjectState>(
        builder: (BuildContext context, ProjectState state) {
          return state.maybeWhen(
            initial: () {
              context.read<ProjectBloc>().add(
                    ProjectEvent.fetchProject(
                      projectId: int.parse(widget.projectId),
                    ),
                  );
              return const Scaffold(
                body: CircularProgressIndicator(),
              );
            },
            loadInProgress: () {
              return const Scaffold(
                body: CircularProgressIndicator(),
              );
            },
            fetchProjectSuccess: (Project project) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(project.title),
                  automaticallyImplyLeading: false,
                  leading: BackButton(
                    onPressed: () {
                      context.pop();
                    },
                  ),
                  actions: <Widget>[
                    _buildActionButton(
                      context: context,
                      theme: theme,
                    ),
                  ],
                ),
                body: Column(
                  children: <Widget>[
                    _buildTabBar(theme: theme),
                    _buildTabBarView(
                      theme: theme,
                      currentUserRole: project.currentUserRole,
                    ),
                  ],
                ),
              );
            },
            fetchProjectFailure: () {
              return const Scaffold(
                body: Center(
                  child: Text('Something went wrong.'),
                ),
              );
            },
            orElse: () => const SizedBox(),
          );
        },
      ),
    );
  }

  TabBar _buildTabBar({
    required ThemeData theme,
  }) {
    return TabBar(
      controller: _tabController,
      onTap: (int index) {
        _tabController.index = index;
        setState(() {});
      },
      tabs: <Tab>[
        _buildTab(
          theme: theme,
          title: 'Tasks',
        ),
        _buildTab(
          theme: theme,
          title: 'Notes',
        ),
        _buildTab(
          theme: theme,
          title: 'Documents',
        ),
      ],
      indicatorColor: theme.colorScheme.primaryContainer,
    );
  }

  Tab _buildTab({
    required ThemeData theme,
    required String title,
  }) {
    return Tab(
      child: Text(
        title,
        style: theme.textTheme.bodyMedium,
      ),
    );
  }

  Expanded _buildTabBarView({
    required ThemeData theme,
    required int currentUserRole,
  }) {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: <Widget>[
          BlocProvider<TasksBloc>(
            create: (BuildContext context) => TasksBloc(
              tasksRepository: TasksRepository(
                dio: context.read<Dio>(),
                dioConfig: context.read<DioConfig>(),
              ),
            )..add(
                TasksEvent.fetchTasks(
                  projectId: int.parse(widget.projectId),
                ),
              ),
            child: TasksScreen(
              projectId: widget.projectId,
              currentUserRole: currentUserRole,
            ),
          ),
          BlocProvider<NotesBloc>(
            create: (BuildContext context) => NotesBloc(
              notesRepository: NotesRepository(
                dio: context.read<Dio>(),
                dioConfig: context.read<DioConfig>(),
              ),
            )..add(
                NotesEvent.fetchNotes(
                  projectId: int.parse(widget.projectId),
                ),
              ),
            child: NotesScreen(
              projectId: widget.projectId,
              currentUserRole: currentUserRole,
            ),
          ),
          BlocProvider<DocumentsBloc>(
            create: (BuildContext context) => DocumentsBloc(
              documentsRepository: DocumentsRepository(
                dio: context.read<Dio>(),
                dioConfig: context.read<DioConfig>(),
              ),
            ),
            child: DocumentsScreen(
              projectId: widget.projectId,
              currentUserRole: currentUserRole,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required ThemeData theme,
  }) {
    return IconButton(
      onPressed: () async {
        final bool? isDeleted = await context.pushNamed(
          RouteConstants.projectDetail,
          params: <String, String>{
            'projectId': widget.projectId,
          },
        );
        if (mounted && (isDeleted ?? false)) {
          context.pop();
        }
      },
      icon: const Icon(Icons.settings),
    );
  }
}
