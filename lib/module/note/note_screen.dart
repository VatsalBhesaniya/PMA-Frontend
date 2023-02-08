import 'dart:convert';

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
      child: BlocBuilder<NoteBloc, NoteState>(
        builder: (BuildContext context, NoteState state) {
          return state.when(
            initial: () {
              context.read<NoteBloc>().add(
                    NoteEvent.fetchNote(
                      noteId: int.parse(widget.noteId),
                    ),
                  );
              return const CircularProgressIndicator();
            },
            loadInProgress: () {
              return const CircularProgressIndicator();
            },
            fetchNoteSuccess: (Note note) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Note Detail'),
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
                          _buildDescription(theme),
                          Text(
                            note.description ?? '',
                            style: theme.textTheme.bodyLarge,
                          ),
                          Text('Created At: ${_dateTime(note.createdAt)}'),
                          _buildUpdatedAt(note.updatedAt),
                          Text('Last updated by: ${note.lastUpdatedBy}'),
                          MaterialButton(
                            onPressed: () {
                              print(jsonEncode(
                                  _controller.document.toDelta().toJson()));
                              print(_controller.document.toPlainText());
                            },
                            color: Colors.lightBlue,
                            child: const Text('Press Me'),
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
          );
        },
      ),
    );
  }

  String _dateTime(String timestamp) {
    final DateTime datetime = DateTime.parse(timestamp).toLocal();
    return DateFormat('EEEE MMM d, y h:mm a ').format(datetime) +
        datetime.timeZoneName;
  }

  Widget _buildUpdatedAt(String? updatedAt) {
    final String? timestamp = updatedAt;
    if (timestamp != null) {
      return Text('Updated At: ${_dateTime(timestamp)}');
    }
    return const SizedBox();
  }

  Widget _buildDescription(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: const BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      child: TextEditor(controller: _controller),
    );
  }
}
