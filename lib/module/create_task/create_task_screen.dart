import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:go_router_flow/go_router_flow.dart';
import 'package:pma/models/create_task.dart';
import 'package:pma/module/create_task/bloc/create_task_bloc.dart';
import 'package:pma/module/create_task/create_task_repository.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';
import 'package:pma/widgets/input_field.dart';
import 'package:pma/widgets/pma_alert_dialog.dart';
import 'package:pma/widgets/snackbar.dart';
import 'package:pma/widgets/text_editor.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({
    required this.projectId,
    super.key,
  });

  final String projectId;

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
              dioClient: context.read<DioClient>(),
            ),
          ),
          child: BlocConsumer<CreateTaskBloc, CreateTaskState>(
            listener: (BuildContext context, CreateTaskState state) {
              state.maybeWhen(
                createTaskSuccess: (int taskId) {
                  showSnackBar(
                    context: context,
                    theme: theme,
                    message: 'Task successfully created.',
                  );
                  context.pop();
                },
                createTaskFailure: (NetworkExceptions error) {
                  pmaAlertDialog(
                    context: context,
                    theme: theme,
                    error:
                        'Could not create task successfully. Please try again.',
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
                          _buildTitle(),
                          const SizedBox(height: 16),
                          _buildDescription(theme: theme),
                          const SizedBox(height: 32),
                          _buildCreateButton(
                            context: context,
                            theme: theme,
                          ),
                          const SizedBox(height: 32),
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

  InputField _buildTitle() {
    return InputField(
      controller: _taskTitleController,
      hintText: 'Title',
      borderType: InputFieldBorderType.underlineInputBorder,
      validator: (String? value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter title';
        }
        return null;
      },
    );
  }

  Widget _buildDescription({
    required ThemeData theme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimary,
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

  ElevatedButton _buildCreateButton({
    required BuildContext context,
    required ThemeData theme,
  }) {
    return ElevatedButton(
      onPressed: () {
        _onCreate(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Create',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.background,
          ),
        ),
      ),
    );
  }

  void _onCreate(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<CreateTaskBloc>().add(
            CreateTaskEvent.createTask(
              task: CreateTask(
                projectId: int.parse(widget.projectId),
                title: _taskTitleController.text.trim(),
                description: _contentController.document.toDelta().toJson(),
                descriptionPlainText: _contentController.document.toPlainText(),
              ),
            ),
          );
    }
  }
}
