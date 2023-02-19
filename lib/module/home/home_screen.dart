import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/models/project.dart';
import 'package:pma/module/home/bloc/home_bloc.dart';
import 'package:pma/module/home/projects_repository.dart';
import 'package:pma/utils/dio_client.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (BuildContext context) => HomeBloc(
        projectsRepository: ProjectsRepository(
          dioClient: context.read<DioClient>(),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                context.goNamed(RouteConstants.settings);
              },
              icon: const CircleAvatar(
                child: Icon(
                  Icons.person_outline_rounded,
                ),
              ),
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
