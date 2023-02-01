import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/models/project.dart';
import 'package:pma/project/bloc/project_bloc.dart';
import 'package:pma/project/project_repository.dart';

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
              return Scaffold(
                appBar: AppBar(
                  title: Text(project.title),
                ),
                body: Column(
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () => context.goNamed(RouteConstants.home),
                      child: const Text('Go back to the Home screen'),
                    ),
                    Text(project.createdAt),
                    Text(project.createdBy.toString()),
                  ],
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
