import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/models/note.dart';
import 'package:pma/module/Notes/bloc/notes_bloc.dart';
import 'package:pma/utils/network_exceptions.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

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
                  const NotesEvent.fetchNotes(),
                );
            _showSnackBar(context: context, theme: theme);
          },
          deleteNoteFailure: (NetworkExceptions error) {
            _buildDeleteNoteFailureAlert(
              context: context,
              theme: theme,
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
                  const NotesEvent.fetchNotes(),
                );
            return const CircularProgressIndicator();
          },
          loadInProgress: () {
            return const CircularProgressIndicator();
          },
          fetchNotesSuccess: (List<Note> notes) {
            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (BuildContext context, int index) {
                final Note note = notes[index];
                return ListTile(
                  onTap: () {
                    context.goNamed(
                      RouteConstants.note,
                      params: <String, String>{
                        'id': note.id.toString(),
                      },
                    );
                  },
                  title: Text(note.title),
                  trailing: IconButton(
                    onPressed: () {
                      _showDeleteNoteConfirmDialog(
                        context: context,
                        theme: theme,
                        noteId: note.id,
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
          'Note successfully deleted',
          textAlign: TextAlign.center,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  void _buildDeleteNoteFailureAlert({
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
            'Could not delete a note successfully. Please try again.',
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
