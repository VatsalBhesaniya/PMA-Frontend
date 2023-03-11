import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pma/config/http_client_config.dart';
import 'package:pma/models/note.dart';
import 'package:pma/models/user.dart';
import 'package:pma/module/note/bloc/note_bloc.dart';
import 'package:pma/module/note/note_repository.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';
import 'package:pma/widgets/input_field.dart';
import 'package:pma/widgets/pma_alert_dialog.dart';
import 'package:pma/widgets/snackbar.dart';
import 'package:pma/widgets/text_editor.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({
    required this.projectId,
    required this.noteId,
    super.key,
  });

  final String projectId;
  final String noteId;

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final quill.QuillController _controller = quill.QuillController.basic();
  final TextEditingController _noteTitleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return BlocProvider<NoteBloc>(
      create: (BuildContext context) => NoteBloc(
        noteRepository: NoteRepository(
          dioClient: context.read<DioClient>(),
          httpClient: context.read<HttpClientConfig>(),
        ),
      ),
      child: BlocConsumer<NoteBloc, NoteState>(
        listener: (BuildContext context, NoteState state) {
          state.maybeWhen(
            updateNoteFailure: () async {
              pmaAlertDialog(
                context: context,
                theme: theme,
                error: 'Could not update note successfully. Please try again.',
              );
            },
            deleteNoteSuccess: () {
              context.pop();
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
        buildWhen: (NoteState previous, NoteState current) {
          return current.maybeWhen(
            updateNoteFailure: () => false,
            deleteNoteSuccess: () => false,
            deleteNoteFailure: (NetworkExceptions error) => false,
            orElse: () => true,
          );
        },
        builder: (BuildContext context, NoteState state) {
          return state.maybeWhen(
            initial: () {
              context.read<NoteBloc>().add(
                    NoteEvent.fetchNote(
                      noteId: int.parse(widget.noteId),
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
            fetchNoteSuccess: (Note note) {
              if (note.content != null) {
                _controller.document =
                    quill.Document.fromJson(note.content ?? <dynamic>[]);
              }
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Note Detail'),
                  actions: note.currentUserRole == MemberRole.guest.index + 1
                      ? null
                      : <Widget>[
                          _buildActionButton(
                            context: context,
                            theme: theme,
                            note: note,
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
                          _buildTitle(note, theme),
                          const SizedBox(height: 16),
                          _buildDescription(
                            theme: theme,
                            isEdit: note.isEdit,
                          ),
                          const SizedBox(height: 32),
                          _buildInfoItem(
                            theme: theme,
                            title: 'Created At',
                            info: _dateTime(note.createdAt),
                          ),
                          const SizedBox(height: 16),
                          _buildUpdatedAt(
                            theme: theme,
                            updatedAt: note.updatedAt,
                          ),
                          const SizedBox(height: 16),
                          _buildLastUpdatedBy(
                            theme: theme,
                            lastUpdatedByUser: note.lastUpdatedByUser,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            fetchNoteFailure: () {
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

  InputField _buildTitle(Note note, ThemeData theme) {
    return InputField(
      controller: _noteTitleController..text = note.title,
      isEnabled: note.isEdit,
      hintText: 'Title',
      borderType: note.isEdit
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
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required ThemeData theme,
    required Note note,
  }) {
    if (note.isEdit) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: <Widget>[
            TextButton(
              onPressed: () {
                context.read<NoteBloc>().add(
                      NoteEvent.updateNote(
                        note: note.copyWith(
                          title: _noteTitleController.text.trim(),
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
                context.read<NoteBloc>().add(
                      NoteEvent.editNote(
                        note: note.copyWith(
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
        IconButton(
          onPressed: () {
            context.read<NoteBloc>().add(
                  NoteEvent.editNote(
                    note: note.copyWith(
                      isEdit: true,
                    ),
                  ),
                );
          },
          icon: const Icon(Icons.edit_note_rounded),
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
                context.read<NoteBloc>().add(
                      NoteEvent.deleteNote(noteId: noteId),
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
