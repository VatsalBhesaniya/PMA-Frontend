import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router_flow/go_router_flow.dart';
import 'package:pma/constants/enum.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/models/note.dart';
import 'package:pma/module/Notes/bloc/notes_bloc.dart';
import 'package:pma/utils/network_exceptions.dart';
import 'package:pma/widgets/pma_alert_dialog.dart';
import 'package:pma/widgets/snackbar.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({
    required this.projectId,
    required this.currentUserRole,
    super.key,
  });

  final String projectId;
  final int currentUserRole;

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return BlocConsumer<NotesBloc, NotesState>(
      listener: (BuildContext context, NotesState state) {
        state.maybeWhen(
          deleteNoteSuccess: () {
            context.read<NotesBloc>().add(
                  NotesEvent.fetchNotes(
                    projectId: int.parse(widget.projectId),
                  ),
                );
            showSnackBar(
              context: context,
              theme: theme,
              message: 'Note successfully deleted',
            );
          },
          deleteNoteFailure: (NetworkExceptions error) {
            pmaAlertDialog(
              context: context,
              theme: theme,
              error: 'Could not delete note successfully. Please try again.',
            );
          },
          orElse: () => null,
        );
      },
      buildWhen: (NotesState previous, NotesState current) {
        return current.maybeWhen(
          deleteNoteSuccess: () => false,
          deleteNoteFailure: (NetworkExceptions error) => false,
          orElse: () => true,
        );
      },
      builder: (BuildContext context, NotesState state) {
        return state.maybeWhen(
          initial: () {
            context.read<NotesBloc>().add(
                  NotesEvent.fetchNotes(
                    projectId: int.parse(widget.projectId),
                  ),
                );
            return const CircularProgressIndicator();
          },
          loadInProgress: () {
            return const CircularProgressIndicator();
          },
          fetchNotesSuccess: (List<Note> notes) {
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
                itemCount: notes.length,
                itemBuilder: (BuildContext context, int index) {
                  final Note note = notes[index];
                  return ListTile(
                    onTap: () async {
                      await context.pushNamed(
                        RouteConstants.note,
                        params: <String, String>{
                          'projectId': widget.projectId,
                          'id': note.id.toString(),
                        },
                      );
                      if (mounted) {
                        context.read<NotesBloc>().add(
                              NotesEvent.fetchNotes(
                                projectId: int.parse(widget.projectId),
                              ),
                            );
                      }
                    },
                    title: Text(note.title),
                    trailing:
                        widget.currentUserRole == MemberRole.guest.index + 1
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _showDeleteNoteConfirmDialog(
                                    context: context,
                                    theme: theme,
                                    noteId: note.id,
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
          fetchNotesFailure: () {
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
        final int? noteId = await context.pushNamed(
          RouteConstants.createNote,
          params: <String, String>{
            'projectId': widget.projectId,
          },
        );
        if (mounted && noteId != null) {
          await context.pushNamed(
            RouteConstants.note,
            params: <String, String>{
              'projectId': widget.projectId,
              'id': noteId.toString(),
            },
          );
          if (mounted) {
            context.read<NotesBloc>().add(
                  NotesEvent.fetchNotes(
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

  void _showDeleteNoteConfirmDialog({
    required BuildContext context,
    required ThemeData theme,
    required int noteId,
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
            'Are you sure you want to delete this note?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                context.read<NotesBloc>().add(
                      NotesEvent.deleteNote(noteId: noteId),
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
