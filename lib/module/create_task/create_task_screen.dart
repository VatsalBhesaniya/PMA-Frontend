import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:go_router/go_router.dart';
import 'package:pma/config/http_client_config.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/models/create_task.dart';
import 'package:pma/module/create_task/bloc/create_task_bloc.dart';
import 'package:pma/module/create_task/create_task_repository.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';
import 'package:pma/widgets/input_field.dart';
import 'package:pma/widgets/text_editor.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _taskTitleController = TextEditingController();
  final QuillController _contentController = QuillController.basic();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
      ),
      body: SafeArea(
        child: BlocProvider<CreateTaskBloc>(
          create: (BuildContext context) => CreateTaskBloc(
            createTaskRepository: CreateTaskRepository(
              httpClient: context.read<HttpClientConfig>(),
            ),
          ),
          child: BlocConsumer<CreateTaskBloc, CreateTaskState>(
            listener: (BuildContext context, CreateTaskState state) {
              state.maybeWhen(
                createTaskSuccess: (int taskId) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Task successfully created.'),
                    ),
                  );
                  context.pop();
                  context.goNamed(
                    RouteConstants.task,
                    params: <String, String>{
                      'id': taskId.toString(),
                    },
                  );
                },
                createTaskFailure: (NetworkExceptions error) {
                  _buildCreateTaskFailureAlert(
                    context: context,
                    theme: theme,
                  );
                },
                orElse: () => null,
              );
            },
            buildWhen: (CreateTaskState previous, CreateTaskState current) {
              return current.maybeWhen(
                initial: () => true,
                orElse: () => false,
              );
            },
            builder: (BuildContext context, CreateTaskState state) {
              return state.maybeWhen(
                loadInProgress: () {
                  return const CircularProgressIndicator();
                },
                initial: () {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          InputField(
                            onChanged: (String value) {},
                            controller: _taskTitleController,
                            hintText: 'Title',
                            borderType:
                                InputFieldBorderType.underlineInputBorder,
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter title';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildDescription(theme: theme),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<CreateTaskBloc>().add(
                                      CreateTaskEvent.createTask(
                                        task: CreateTask(
                                          title:
                                              _taskTitleController.text.trim(),
                                          description: _contentController
                                              .document
                                              .toDelta()
                                              .toJson(),
                                          descriptionPlainText:
                                              _contentController.document
                                                  .toPlainText(),
                                        ),
                                      ),
                                    );
                              }
                            },
                            child: const Text('Create'),
                          ),
                        ],
                      ),
                    ),
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

  Widget _buildDescription({
    required ThemeData theme,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: const BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      child: TextEditor(
        controller: _contentController,
      ),
    );
  }

  void _buildCreateTaskFailureAlert({
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
            'Someth ing went wrong!. Please try again.',
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
