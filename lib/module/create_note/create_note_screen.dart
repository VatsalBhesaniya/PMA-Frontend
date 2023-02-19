import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:go_router/go_router.dart';
import 'package:pma/config/http_client_config.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/models/create_note.dart';
import 'package:pma/module/create_note/bloc/create_note_bloc.dart';
import 'package:pma/module/create_note/create_note_repository.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';
import 'package:pma/widgets/input_field.dart';
import 'package:pma/widgets/text_editor.dart';

class CreateNoteScreen extends StatefulWidget {
  const CreateNoteScreen({super.key});

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
              httpClient: context.read<HttpClientConfig>(),
            ),
          ),
          child: BlocConsumer<CreateNoteBloc, CreateNoteState>(
            listener: (BuildContext context, CreateNoteState state) {
              state.maybeWhen(
                createNoteSuccess: (int noteId) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Note successfully created.'),
                    ),
                  );
                  context.pop();
                  context.goNamed(
                    RouteConstants.note,
                    params: <String, String>{
                      'id': noteId.toString(),
                    },
                  );
                },
                createNoteFailure: (NetworkExceptions error) {
                  _buildCreateNoteFailureAlert(
                    context: context,
                    theme: theme,
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
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<CreateNoteBloc>().add(
                                      CreateNoteEvent.createNote(
                                        note: CreateNote(
                                          title:
                                              _noteTitleController.text.trim(),
                                          content: _contentController.document
                                              .toDelta()
                                              .toJson(),
                                          contentPlainText: _contentController
                                              .document
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

  void _buildCreateNoteFailureAlert({
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
