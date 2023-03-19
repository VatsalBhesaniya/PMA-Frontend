import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router_flow/go_router_flow.dart';
import 'package:pma/constants/enum.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/models/document.dart';
import 'package:pma/module/Documents/bloc/documents_bloc.dart';
import 'package:pma/utils/network_exceptions.dart';
import 'package:pma/widgets/pma_alert_dialog.dart';
import 'package:pma/widgets/snackbar.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({
    required this.projectId,
    required this.currentUserRole,
    super.key,
  });

  final String projectId;
  final int currentUserRole;

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
                  DocumentsEvent.fetchDocuments(
                    projectId: int.parse(widget.projectId),
                  ),
                );
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
                  DocumentsEvent.fetchDocuments(
                    projectId: int.parse(widget.projectId),
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
          fetchDocumentsSuccess: (List<Document> documents) {
            return Scaffold(
              floatingActionButton:
                  widget.currentUserRole == MemberRole.guest.index + 1
                      ? null
                      : _buildFloatingActionButton(
                          context: context,
                          theme: theme,
                        ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              body: ListView.separated(
                padding: const EdgeInsets.only(top: 16, bottom: 80),
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 20,
                  );
                },
                itemCount: documents.length,
                itemBuilder: (BuildContext context, int index) {
                  final Document document = documents[index];
                  return ListTile(
                    onTap: () async {
                      await context.pushNamed(
                        RouteConstants.document,
                        params: <String, String>{
                          'projectId': widget.projectId,
                          'id': document.id.toString(),
                        },
                      );
                      if (mounted) {
                        context.read<DocumentsBloc>().add(
                              DocumentsEvent.fetchDocuments(
                                projectId: int.parse(widget.projectId),
                              ),
                            );
                      }
                    },
                    title: Text(document.title),
                    trailing:
                        widget.currentUserRole == MemberRole.guest.index + 1
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _showDeleteDocumentConfirmDialog(
                                    context: context,
                                    theme: theme,
                                    documentId: document.id,
                                  );
                                },
                                color: theme.colorScheme.onError,
                                icon: const Icon(
                                  Icons.delete_rounded,
                                ),
                              ),
                  );
                },
              ),
            );
          },
          fetchDocumentsFailure: (NetworkExceptions error) {
            return const Center(
              child: Text('Something went wrong.'),
            );
          },
          orElse: () => const SizedBox(),
        );
      },
    );
  }

  FloatingActionButton _buildFloatingActionButton({
    required BuildContext context,
    required ThemeData theme,
  }) {
    return FloatingActionButton(
      onPressed: () async {
        final int? documentId = await context.pushNamed(
          RouteConstants.createDocument,
          params: <String, String>{
            'projectId': widget.projectId,
          },
        );
        if (mounted && documentId != null) {
          await context.pushNamed(
            RouteConstants.document,
            params: <String, String>{
              'projectId': widget.projectId,
              'id': documentId.toString(),
            },
          );
          if (mounted) {
            context.read<DocumentsBloc>().add(
                  DocumentsEvent.fetchDocuments(
                    projectId: int.parse(widget.projectId),
                  ),
                );
          }
        }
      },
      child: Icon(
        Icons.add,
        color: theme.colorScheme.primary,
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
                context.read<DocumentsBloc>().add(
                      DocumentsEvent.deleteDocument(documentId: documentId),
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
