import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/models/project.dart';
import 'package:pma/module/invited_projects/bloc/invited_projects_bloc.dart';

class InvitedPorojectsScreen extends StatefulWidget {
  const InvitedPorojectsScreen({super.key});

  @override
  State<InvitedPorojectsScreen> createState() => _InvitedPorojectsScreenState();
}

class _InvitedPorojectsScreenState extends State<InvitedPorojectsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<InvitedProjectsBloc, InvitedProjectsState>(
          builder: (BuildContext context, InvitedProjectsState state) {
            return state.maybeWhen(
              initial: () {
                context.read<InvitedProjectsBloc>().add(
                      const InvitedProjectsEvent.fetchInvitedProjects(),
                    );
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              loadInProgress: () {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              fetchInvitedProjectsSuccess: (List<Project> projects) {
                return ListView.builder(
                  itemCount: projects.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Project project = projects[index];
                    return ListTile(
                      onTap: () {
                        context.goNamed(
                          RouteConstants.project,
                          params: <String, String>{
                            'id': project.id.toString(),
                          },
                        );
                      },
                      title: Text(project.title),
                    );
                  },
                );
              },
              fetchInvitedProjectsFailure: () {
                return const Center(
                  child: Text('Something went wrong.'),
                );
              },
              orElse: () => const SizedBox(),
            );
          },
        ),
      ),
    );
  }
}
