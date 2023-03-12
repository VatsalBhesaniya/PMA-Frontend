import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pma/models/document.dart';
import 'package:pma/models/user.dart';
import 'package:pma/module/document/bloc/document_bloc.dart';
import 'package:pma/module/document/document_repository.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';
import 'package:pma/widgets/input_field.dart';
import 'package:pma/widgets/pma_alert_dialog.dart';
import 'package:pma/widgets/snackbar.dart';
import 'package:pma/widgets/text_editor.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({
    required this.projectId,
    required this.documentId,
    super.key,
  });

  final String projectId;
  final String documentId;

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  final quill.QuillController _controller = quill.QuillController.basic();
  final TextEditingController _documentTitleController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return BlocProvider<DocumentBloc>(
      create: (BuildContext context) => DocumentBloc(
        documentRepository: DocumentRepository(
          dioClient: context.read<DioClient>(),
        ),
      ),
      child: BlocConsumer<DocumentBloc, DocumentState>(
        listener: (BuildContext context, DocumentState state) {
          state.maybeWhen(
            updateDocumentFailure: () async {
              pmaAlertDialog(
                context: context,
                theme: theme,
                error:
                    'Could not update document successfully. Please try again.',
              );
            },
            deleteDocumentSuccess: () {
              context.pop();
              showSnackBar(
                context: context,
                theme: theme,
                message: 'Document successfully deleted',
              );
            },
            deleteDocumentFailure: (NetworkExceptions error) {
              pmaAlertDialog(
                context: context,
                theme: theme,
                error:
                    'Could not delete document successfully. Please try again.',
              );
            },
            orElse: () => null,
          );
        },
        buildWhen: (DocumentState previous, DocumentState current) {
          return current.maybeWhen(
            updateDocumentFailure: () => false,
            deleteDocumentSuccess: () => false,
            deleteDocumentFailure: (NetworkExceptions error) => false,
            orElse: () => true,
          );
        },
        builder: (BuildContext context, DocumentState state) {
          return state.maybeWhen(
            initial: () {
              context.read<DocumentBloc>().add(
                    DocumentEvent.fetchDocument(
                      documentId: int.parse(widget.documentId),
                    ),
                  );
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
            loadInProgress: () {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
            fetchDocumentSuccess: (Document document) {
              if (document.content != null) {
                _controller.document =
                    quill.Document.fromJson(document.content ?? <dynamic>[]);
              }
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Document Detail'),
                  actions:
                      document.currentUserRole == MemberRole.guest.index + 1
                          ? null
                          : <Widget>[
                              _buildActionButton(
                                context: context,
                                theme: theme,
                                document: document,
                              ),
                            ],
                ),
                body: SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          InputField(
                            controller: _documentTitleController
                              ..text = document.title,
                            isEnabled: document.isEdit,
                            hintText: 'Title',
                            borderType: document.isEdit
                                ? InputFieldBorderType.underlineInputBorder
                                : InputFieldBorderType.none,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                            horizontalContentPadding: 0,
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter title';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildDescription(
                            theme: theme,
                            isEdit: document.isEdit,
                          ),
                          const SizedBox(height: 32),
                          _buildInfoItem(
                            theme: theme,
                            title: 'Created At',
                            info: _dateTime(document.createdAt),
                          ),
                          const SizedBox(height: 16),
                          _buildUpdatedAt(
                            theme: theme,
                            updatedAt: document.updatedAt,
                          ),
                          const SizedBox(height: 16),
                          _buildLastUpdatedBy(
                            theme: theme,
                            lastUpdatedByUser: document.lastUpdatedByUser,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            fetchDocumentFailure: () {
              return const Center(
                child: Text('Something went wrong.'),
              );
            },
            orElse: () => const SizedBox(),
          );
        },
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required ThemeData theme,
    required Document document,
  }) {
    if (document.isEdit) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: <Widget>[
            TextButton(
              onPressed: () {
                context.read<DocumentBloc>().add(
                      DocumentEvent.updateDocument(
                        document: document.copyWith(
                          title: _documentTitleController.text.trim(),
                          content: _controller.document.toDelta().toJson(),
                          contentPlainText: _controller.document.toPlainText(),
                        ),
                      ),
                    );
              },
              child: Text(
                'Save',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primaryContainer,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<DocumentBloc>().add(
                      DocumentEvent.editDocument(
                        document: document.copyWith(
                          isEdit: false,
                        ),
                      ),
                    );
              },
              child: Text(
                'Cancel',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primaryContainer,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Row(
      children: <Widget>[
        IconButton(
          onPressed: () {
            _showDeleteDocumentConfirmDialog(
              context: context,
              theme: theme,
              documentId: document.id,
            );
          },
          icon: const Icon(
            Icons.delete_rounded,
          ),
        ),
        IconButton(
          onPressed: () {
            context.read<DocumentBloc>().add(
                  DocumentEvent.editDocument(
                    document: document.copyWith(
                      isEdit: true,
                    ),
                  ),
                );
          },
          icon: const Icon(Icons.edit_document),
        ),
      ],
    );
  }

  String _dateTime(String timestamp) {
    final DateTime datetime = DateTime.parse(timestamp).toLocal();
    return DateFormat('EEEE MMM d, y h:mm a ').format(datetime) +
        datetime.timeZoneName;
  }

  Widget _buildInfoItem({
    required ThemeData theme,
    required String title,
    required String info,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text(
          info,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildUpdatedAt({
    required ThemeData theme,
    required String? updatedAt,
  }) {
    final String? timestamp = updatedAt;
    if (timestamp != null) {
      return _buildInfoItem(
        theme: theme,
        title: 'Updated At',
        info: _dateTime(timestamp),
      );
    }
    return const SizedBox();
  }

  Widget _buildLastUpdatedBy({
    required ThemeData theme,
    required User? lastUpdatedByUser,
  }) {
    final User? updatedByUser = lastUpdatedByUser;
    if (updatedByUser != null) {
      return _buildInfoItem(
        theme: theme,
        title: 'Last updated by',
        info: updatedByUser.username,
      );
    }
    return const SizedBox();
  }

  Widget _buildDescription({
    required ThemeData theme,
    required bool isEdit,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: const BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      child: TextEditor(
        controller: _controller,
        readOnly: !isEdit,
        showCursor: isEdit,
      ),
    );
  }

  void _showDeleteDocumentConfirmDialog({
    required BuildContext context,
    required ThemeData theme,
    required int documentId,
  }) {
    showDialog<String>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Confirm',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
          content: const Text(
            'Are you sure you want to delete this document?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                context.read<DocumentBloc>().add(
                      DocumentEvent.deleteDocument(documentId: documentId),
                    );
                Navigator.pop(ctx);
              },
              child: Text(
                'OK',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
