import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';

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
          dioClient: context.read<DioClient>(),
        ),
      ),
      child: BlocConsumer<ProjectBloc, ProjectState>(
        listener: (BuildContext context, ProjectState state) {
          state.maybeWhen(
            deleteProjectSuccess: () {
              context.pop();
              _showSnackBar(context: context, theme: theme);
            },
            deleteProjectFailure: (NetworkExceptions error) {
              _buildDeleteProjectFailureAlert(
                context: context,
                theme: theme,
              );
            },
            orElse: () => null,
          );
        },
        buildWhen: (ProjectState previous, ProjectState current) {
          return current.maybeWhen(
            deleteProjectSuccess: () => false,
            deleteProjectFailure: (NetworkExceptions error) => false,
            orElse: () => true,
          );
        },
        builder: (BuildContext context, ProjectState state) {
          return state.maybeWhen(
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
              return Scaffold(
                appBar: AppBar(
                  title: Text(project.title),
                  actions: <Widget>[
                    _buildActionButton(
                      context: context,
                      theme: theme,
                      project: project,
                    ),
                  ],
                ),
                floatingActionButton: _buildFloatingActionButton(),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                body: Column(
                  children: <Widget>[
                    _buildTabBar(theme: theme),
                    _buildTabBarView(theme: theme),
                  ],
                ),
              );
            },
            fetchProjectFailure: () {
              return const Center(
                child: Text('Something went wrong.'),
              );
            },
            orElse: () => const SizedBox(),
          );
        },
      ),
    );
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        switch (_tabController.index) {
          case 0:
            context.goNamed(
              RouteConstants.createTask,
            );
            break;
          case 1:
            context.goNamed(
              RouteConstants.createNote,
            );
            break;
          case 2:
            context.goNamed(
              RouteConstants.createDocument,
            );
            break;
          default:
        }
      },
      child: const Icon(Icons.add),
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
    );
  }

  Tab _buildTab({
    required ThemeData theme,
    required String title,
  }) {
    return Tab(
      child: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }

  Expanded _buildTabBarView({
    required ThemeData theme,
  }) {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: <Widget>[
          BlocProvider<TasksBloc>(
            create: (BuildContext context) => TasksBloc(
              tasksRepository: TasksRepository(
                dioClient: context.read<DioClient>(),
              ),
            ),
            child: const TasksScreen(),
          ),
          BlocProvider<NotesBloc>(
            create: (BuildContext context) => NotesBloc(
              notesRepository: NotesRepository(
                dioClient: context.read<DioClient>(),
              ),
            ),
            child: const NotesScreen(),
          ),
          BlocProvider<DocumentsBloc>(
            create: (BuildContext context) => DocumentsBloc(
              documentsRepository: DocumentsRepository(
                dioClient: context.read<DioClient>(),
              ),
            ),
            child: const DocumentsScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required ThemeData theme,
    required Project project,
  }) {
    return Row(
      children: <Widget>[
        IconButton(
          onPressed: () {
            _showDeleteNoteConfirmDialog(
              context: context,
              theme: theme,
              projectId: project.id,
            );
          },
          icon: const Icon(
            Icons.delete_rounded,
          ),
        ),
        IconButton(
          onPressed: () {
            context.goNamed(
              RouteConstants.projectDetail,
              params: <String, String>{
                'id': widget.projectId,
                'projectId': widget.projectId,
              },
            );
          },
          icon: const Icon(Icons.settings),
        ),
      ],
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
          'Project successfully deleted',
          textAlign: TextAlign.center,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  void _buildDeleteProjectFailureAlert({
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
            'Could not delete a project successfully. Please try again.',
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

  void _showDeleteNoteConfirmDialog({
    required BuildContext context,
    required ThemeData theme,
    required int projectId,
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
            'Are you sure you want to delete this project?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                context.read<ProjectBloc>().add(
                      ProjectEvent.deleteProject(projectId: projectId),
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
