import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:go_router/go_router.dart';
import 'package:pma/config/http_client_config.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/models/create_document.dart';
import 'package:pma/module/create_document/bloc/create_document_bloc.dart';
import 'package:pma/module/create_document/create_document_repository.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';
import 'package:pma/widgets/input_field.dart';
import 'package:pma/widgets/text_editor.dart';

class CreateDocumentScreen extends StatefulWidget {
  const CreateDocumentScreen({super.key});

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
              httpClient: context.read<HttpClientConfig>(),
            ),
          ),
          child: BlocConsumer<CreateDocumentBloc, CreateDocumentState>(
            listener: (BuildContext context, CreateDocumentState state) {
              state.maybeWhen(
                createDocumentSuccess: (int documentId) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Document successfully created.'),
                    ),
                  );
                  context.pop();
                  context.goNamed(
                    RouteConstants.document,
                    params: <String, String>{
                      'id': documentId.toString(),
                    },
                  );
                },
                createDocumentFailure: (NetworkExceptions error) {
                  _buildCreateDocumentFailureAlert(
                    context: context,
                    theme: theme,
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
                            onChanged: (String value) {},
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
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<CreateDocumentBloc>().add(
                                      CreateDocumentEvent.createDocument(
                                        document: CreateDocument(
                                          title: _documentTitleController.text
                                              .trim(),
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

  void _buildCreateDocumentFailureAlert({
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
