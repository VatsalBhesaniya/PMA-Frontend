import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pma/models/note.dart';
import 'package:pma/module/note/bloc/note_bloc.dart';
import 'package:pma/module/note/note_repository.dart';

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
  @override
  Widget build(BuildContext context) {
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
                  title: Text(note.title),
                ),
                body: SafeArea(
                  child: Column(
                    children: <Widget>[
                      const Text('Created At'),
                      Text(note.createdAt),
                    ],
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
}
