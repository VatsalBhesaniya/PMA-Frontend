import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router_flow/go_router_flow.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/models/project.dart';
import 'package:pma/module/invited_projects/bloc/invited_projects_bloc.dart';
import 'package:pma/utils/network_exceptions.dart';

class InvitedPorojectsScreen extends StatefulWidget {
  const InvitedPorojectsScreen({super.key});

  @override
  State<InvitedPorojectsScreen> createState() => _InvitedPorojectsScreenState();
}

class _InvitedPorojectsScreenState extends State<InvitedPorojectsScreen> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
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
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider();
                  },
                  itemCount: projects.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Project project = projects[index];
                    return ListTile(
                      onTap: () async {
                        await context.pushNamed(
                          RouteConstants.project,
                          params: <String, String>{
                            'projectId': project.id.toString(),
                          },
                        );
                        if (mounted) {
                          context.read<InvitedProjectsBloc>().add(
                                const InvitedProjectsEvent
                                    .fetchInvitedProjects(),
                              );
                        }
                      },
                      title: Text(
                        project.title,
                        style: theme.textTheme.titleMedium,
                      ),
                    );
                  },
                );
              },
              fetchInvitedProjectsFailure: (NetworkExceptions error) {
                return Center(
                  child: Text(
                    'Something went wrong.',
                    style: theme.textTheme.bodyMedium,
                  ),
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
