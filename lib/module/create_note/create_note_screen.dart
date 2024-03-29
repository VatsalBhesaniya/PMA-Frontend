import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:go_router_flow/go_router_flow.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/enum.dart';
import 'package:pma/models/create_note.dart';
import 'package:pma/module/create_note/bloc/create_note_bloc.dart';
import 'package:pma/module/create_note/create_note_repository.dart';
import 'package:pma/utils/network_exceptions.dart';
import 'package:pma/widgets/input_field.dart';
import 'package:pma/widgets/pma_alert_dialog.dart';
import 'package:pma/widgets/snackbar.dart';
import 'package:pma/widgets/text_editor.dart';

class CreateNoteScreen extends StatefulWidget {
  const CreateNoteScreen({
    required this.projectId,
    super.key,
  });

  final String projectId;

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _noteTitleController = TextEditingController();
  final quill.QuillController _contentController =
      quill.QuillController.basic();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Note'),
      ),
      body: SafeArea(
        child: BlocProvider<CreateNoteBloc>(
          create: (BuildContext context) => CreateNoteBloc(
            createNoteRepository: CreateNoteRepository(
              dioConfig: context.read<DioConfig>(),
              dio: context.read<Dio>(),
            ),
          ),
          child: BlocConsumer<CreateNoteBloc, CreateNoteState>(
            listener: (BuildContext context, CreateNoteState state) {
              state.maybeWhen(
                createNoteSuccess: (int noteId) {
                  showSnackBar(
                    context: context,
                    theme: theme,
                    message: 'Note successfully created.',
                  );
                  context.pop(noteId);
                },
                createNoteFailure: (NetworkExceptions error) {
                  pmaAlertDialog(
                    context: context,
                    theme: theme,
                    error:
                        'Could not create note successfully. Please try again.',
                  );
                },
                orElse: () => null,
              );
            },
            buildWhen: (CreateNoteState previous, CreateNoteState current) {
              return current.maybeWhen(
                initial: () => true,
                orElse: () => false,
              );
            },
            builder: (BuildContext context, CreateNoteState state) {
              return state.maybeWhen(
                loadInProgress: () {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                initial: () {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            InputField(
                              controller: _noteTitleController,
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
                            _buildCreateButton(
                              context: context,
                              theme: theme,
                            ),
                          ],
                        ),
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

  ElevatedButton _buildCreateButton({
    required BuildContext context,
    required ThemeData theme,
  }) {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          context.read<CreateNoteBloc>().add(
                CreateNoteEvent.createNote(
                  note: CreateNote(
                    projectId: int.parse(widget.projectId),
                    title: _noteTitleController.text.trim(),
                    content: _contentController.document.toDelta().toJson(),
                    contentPlainText: _contentController.document.toPlainText(),
                  ),
                ),
              );
        }
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
}
