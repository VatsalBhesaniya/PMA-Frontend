import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pma/config/http_client_config.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/models/create_project.dart';
import 'package:pma/models/project.dart';
import 'package:pma/module/home/bloc/home_bloc.dart';
import 'package:pma/module/home/projects_repository.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';
import 'package:pma/widgets/floating_action_button_extended.dart';
import 'package:pma/widgets/input_field.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _projectTitleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Provider<HomeBloc>(
      create: (BuildContext context) => HomeBloc(
        projectsRepository: ProjectsRepository(
          dioClient: context.read<DioClient>(),
          httpClient: context.read<HttpClientConfig>(),
        ),
      ),
      builder: (BuildContext context, Widget? child) => Scaffold(
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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButtonExtended(
          onPressed: () {
            _showCreateProjectDialog(
              context: context,
              theme: theme,
            );
          },
          labelText: 'Create Project',
        ),
        body: SafeArea(
          child: BlocConsumer<HomeBloc, HomeState>(
            listener: (BuildContext context, HomeState state) {
              state.maybeWhen(
                createProjectSuccess: () {
                  context.read<HomeBloc>().add(
                        const HomeEvent.fetchProjects(),
                      );
                },
                createProjectFailure: (NetworkExceptions error) {
                  _buildCreateProjectFailureAlert(
                    context: context,
                    theme: theme,
                  );
                },
                orElse: () => null,
              );
            },
            buildWhen: (HomeState previous, HomeState current) {
              return current.maybeWhen(
                createProjectSuccess: () => false,
                createProjectFailure: (NetworkExceptions error) => false,
                orElse: () => true,
              );
            },
            builder: (BuildContext context, HomeState state) {
              return state.maybeWhen(
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
                orElse: () => const SizedBox(),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showCreateProjectDialog({
    required BuildContext context,
    required ThemeData theme,
  }) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'Create Project',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: InputField(
                    controller: _projectTitleController,
                    hintText: 'Project title',
                    borderType: InputFieldBorderType.underlineInputBorder,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter title';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              MaterialButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    context.read<HomeBloc>().add(
                          HomeEvent.createProject(
                            project: CreateProject(
                              title: _projectTitleController.text.trim(),
                            ),
                          ),
                        );
                    Navigator.pop(ctx, 'OK');
                  }
                },
                color: theme.colorScheme.outline,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(4),
                  ),
                ),
                child: Text(
                  'OK',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _buildCreateProjectFailureAlert({
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
            'Could not create project successfully. Please try again.',
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
}
