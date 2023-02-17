import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/models/document.dart';
import 'package:pma/module/Documents/bloc/documents_bloc.dart';
import 'package:pma/utils/network_exceptions.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return BlocConsumer<DocumentsBloc, DocumentsState>(
      listener: (BuildContext context, DocumentsState state) {
        state.maybeWhen(
          deleteDocumentSuccess: () {
            context.read<DocumentsBloc>().add(
                  const DocumentsEvent.fetchDocuments(),
                );
            _showSnackBar(context: context, theme: theme);
          },
          deleteDocumentFailure: (NetworkExceptions error) {
            _buildDeleteDocumentFailureAlert(
              context: context,
              theme: theme,
            );
          },
          orElse: () => null,
        );
      },
      buildWhen: (DocumentsState previous, DocumentsState current) {
        return current.maybeWhen(
          deleteDocumentSuccess: () => false,
          deleteDocumentFailure: (NetworkExceptions error) => false,
          orElse: () => true,
        );
      },
      builder: (BuildContext context, DocumentsState state) {
        return state.maybeWhen(
          initial: () {
            context.read<DocumentsBloc>().add(
                  const DocumentsEvent.fetchDocuments(),
                );
            return const CircularProgressIndicator();
          },
          loadInProgress: () {
            return const CircularProgressIndicator();
          },
          fetchDocumentsSuccess: (List<Document> documents) {
            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (BuildContext context, int index) {
                final Document document = documents[index];
                return ListTile(
                  onTap: () {
                    context.goNamed(
                      RouteConstants.document,
                      params: <String, String>{
                        'id': document.id.toString(),
                      },
                    );
                  },
                  title: Text(document.title),
                  trailing: IconButton(
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
                );
              },
            );
          },
          fetchDocumentsFailure: () {
            return const Center(
              child: Text('Something went wrong.'),
            );
          },
          orElse: () => const SizedBox(),
        );
      },
    );
  }

  void _showSnackBar({
    required BuildContext context,
    required ThemeData theme,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: const EdgeInsets.all(16),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: theme.colorScheme.surface,
        content: Text(
          'Document successfully deleted',
          textAlign: TextAlign.center,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  void _buildDeleteDocumentFailureAlert({
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
            'Could not delete a document successfully. Please try again.',
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
                context.read<DocumentsBloc>().add(
                      DocumentsEvent.deleteDocument(documentId: documentId),
                    );
                Navigator.pop(ctx);
              },
              child: Text(
                'OK',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
