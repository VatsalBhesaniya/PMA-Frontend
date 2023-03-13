import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router_flow/go_router_flow.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/models/create_project.dart';
import 'package:pma/models/project.dart';
import 'package:pma/module/my_projects/bloc/my_projects_bloc.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';
import 'package:pma/widgets/floating_action_button_extended.dart';
import 'package:pma/widgets/input_field.dart';
import 'package:pma/widgets/pma_alert_dialog.dart';

class MyPorojectsScreen extends StatefulWidget {
  const MyPorojectsScreen({super.key});

  @override
  State<MyPorojectsScreen> createState() => _MyPorojectsScreenState();
}

class _MyPorojectsScreenState extends State<MyPorojectsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _projectTitleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButtonExtended(
        onPressed: () {
          _showCreateProjectDialog(
            context: context,
            theme: theme,
          );
        },
        backgroundColor: theme.colorScheme.primary,
        labelText: 'Create Project',
        labelStyle: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.background,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SafeArea(
        child: BlocConsumer<MyProjectsBloc, MyProjectsState>(
          listener: (BuildContext context, MyProjectsState state) {
            state.maybeWhen(
              createProjectSuccess: () {
                context.read<MyProjectsBloc>().add(
                      const MyProjectsEvent.fetchProjects(),
                    );
              },
              createProjectFailure: (NetworkExceptions error) {
                pmaAlertDialog(
                  context: context,
                  theme: theme,
                  error:
                      'Could not create project successfully. Please try again.',
                );
              },
              orElse: () => null,
            );
          },
          buildWhen: (MyProjectsState previous, MyProjectsState current) {
            return current.maybeWhen(
              createProjectSuccess: () => false,
              createProjectFailure: (NetworkExceptions error) => false,
              orElse: () => true,
            );
          },
          builder: (BuildContext context, MyProjectsState state) {
            return state.maybeWhen(
              initial: () {
                context.read<MyProjectsBloc>().add(
                      const MyProjectsEvent.fetchProjects(),
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
              fetchProjectsSuccess: (List<Project> projects) {
                return ListView.separated(
                  padding: const EdgeInsets.only(top: 16, bottom: 80),
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
                          context.read<MyProjectsBloc>().add(
                                const MyProjectsEvent.fetchProjects(),
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
              fetchProjectsFailure: () {
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

  void _showCreateProjectDialog({
    required BuildContext context,
    required ThemeData theme,
  }) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return Dialog(
          backgroundColor: theme.colorScheme.background,
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
                      icon: const Icon(
                        Icons.close_rounded,
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
                    autofocus: true,
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
                    context.read<MyProjectsBloc>().add(
                          MyProjectsEvent.createProject(
                            project: CreateProject(
                              title: _projectTitleController.text.trim(),
                            ),
                          ),
                        );
                    _projectTitleController.clear();
                    Navigator.pop(ctx, 'OK');
                  }
                },
                color: theme.colorScheme.primary,
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
}
