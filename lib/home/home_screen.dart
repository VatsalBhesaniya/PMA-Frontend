import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pma/authentication/bloc/authentication_bloc.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/home/bloc/home_bloc.dart';
import 'package:pma/home/projects_repository.dart';
import 'package:pma/models/project.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (BuildContext context) => HomeBloc(
        projectsRepository: ProjectsRepository(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                context.read<AuthenticationBloc>().add(Logout());
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
        body: SafeArea(
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (BuildContext context, HomeState state) {
              return state.when(
                initial: () {
                  context.read<HomeBloc>().add(
                        const HomeEvent.fetchProjects(),
                      );
                  return const CircularProgressIndicator();
                },
                loadInProgress: () => const CircularProgressIndicator(),
                fetchProjectsSuccess: (List<Project> projects) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () =>
                            context.goNamed(RouteConstants.details),
                        child: const Text('Go to the Details screen'),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: projects.length,
                          itemBuilder: (BuildContext context, int index) {
                            final Project project = projects[index];
                            return ListTile(
                              title: Text(project.title),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
                fetchProjectsFailure: () {
                  return const Center(
                    child: Text('Something went wrong.'),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
