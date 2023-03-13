import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:go_router_flow/go_router_flow.dart';
import 'package:pma/models/create_document.dart';
import 'package:pma/module/create_document/bloc/create_document_bloc.dart';
import 'package:pma/module/create_document/create_document_repository.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';
import 'package:pma/widgets/input_field.dart';
import 'package:pma/widgets/pma_alert_dialog.dart';
import 'package:pma/widgets/snackbar.dart';
import 'package:pma/widgets/text_editor.dart';

class CreateDocumentScreen extends StatefulWidget {
  const CreateDocumentScreen({
    required this.projectId,
    super.key,
  });

  final String projectId;

  @override
  State<CreateDocumentScreen> createState() => _CreateDocumentScreenState();
}

class _CreateDocumentScreenState extends State<CreateDocumentScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _documentTitleController =
      TextEditingController();
  final quill.QuillController _contentController =
      quill.QuillController.basic();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Document'),
      ),
      body: SafeArea(
        child: BlocProvider<CreateDocumentBloc>(
          create: (BuildContext context) => CreateDocumentBloc(
            createDocumentRepository: CreateDocumentRepository(
              dioClient: context.read<DioClient>(),
            ),
          ),
          child: BlocConsumer<CreateDocumentBloc, CreateDocumentState>(
            listener: (BuildContext context, CreateDocumentState state) {
              state.maybeWhen(
                createDocumentSuccess: (int documentId) {
                  showSnackBar(
                    context: context,
                    theme: theme,
                    message: 'Document successfully created.',
                  );
                  context.pop(documentId);
                },
                createDocumentFailure: (NetworkExceptions error) {
                  pmaAlertDialog(
                    context: context,
                    theme: theme,
                    error:
                        'Could not create document successfully. Please try again.',
                  );
                },
                orElse: () => null,
              );
            },
            buildWhen:
                (CreateDocumentState previous, CreateDocumentState current) {
              return current.maybeWhen(
                initial: () => true,
                orElse: () => false,
              );
            },
            builder: (BuildContext context, CreateDocumentState state) {
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
                            controller: _documentTitleController,
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
          context.read<CreateDocumentBloc>().add(
                CreateDocumentEvent.createDocument(
                  document: CreateDocument(
                    projectId: int.parse(widget.projectId),
                    title: _documentTitleController.text.trim(),
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
