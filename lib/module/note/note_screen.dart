import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:intl/intl.dart';
import 'package:pma/models/note.dart';
import 'package:pma/module/note/bloc/note_bloc.dart';
import 'package:pma/module/note/note_repository.dart';
import 'package:pma/utils/text_editor.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({
    required this.noteId,
    super.key,
  });

  final String noteId;

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final QuillController _controller = QuillController.basic();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return BlocProvider<NoteBloc>(
      create: (BuildContext context) => NoteBloc(
        noteRepository: NoteRepository(),
      ),
      child: BlocConsumer<NoteBloc, NoteState>(
        listener: (BuildContext context, NoteState state) {
          state.maybeWhen(
            updateNoteFailure: () async {
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
            },
            orElse: () => null,
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
                    Document.fromJson(note.content ?? <dynamic>[]);
              }
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Note Detail'),
                  actions: <Widget>[
                    _buildActionButton(
                      context: context,
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
                          Text(
                            note.title,
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          _buildDescription(
                            theme: theme,
                            isEdit: note.isEdit,
                          ),
                          const SizedBox(height: 16),
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
                            lastUpdatedBy: note.lastUpdatedBy,
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

  Widget _buildActionButton({
    required BuildContext context,
    required Note note,
  }) {
    if (note.isEdit) {
      return Row(
        children: <Widget>[
          TextButton(
            onPressed: () {
              context.read<NoteBloc>().add(
                    NoteEvent.updateNote(
                      note: note.copyWith(
                        content: _controller.document.toDelta().toJson(),
                        contentPlainText: _controller.document.toPlainText(),
                      ),
                    ),
                  );
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.lime,
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
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.lime,
              ),
            ),
          ),
        ],
      );
    }
    return IconButton(
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
          style: theme.textTheme.bodyLarge,
        ),
        Text(
          info,
          style: theme.textTheme.bodyMedium,
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
    required int? lastUpdatedBy,
  }) {
    final int? updatedBy = lastUpdatedBy;
    if (updatedBy != null) {
      return _buildInfoItem(
        theme: theme,
        title: 'Last updated by',
        info: updatedBy.toString(),
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
}
