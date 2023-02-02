import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/models/note.dart';
import 'package:pma/module/Notes/bloc/notes_bloc.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotesBloc, NotesState>(
      builder: (BuildContext context, NotesState state) {
        return state.when(
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
                final Note task = notes[index];
                return ListTile(
                  onTap: () {
                    context.goNamed(
                      RouteConstants.task,
                      params: <String, String>{
                        'id': task.id.toString(),
                      },
                    );
                  },
                  title: Text(task.title),
                );
              },
            );
          },
          fetchNotesFailure: () {
            return const Center(
              child: Text('Something went wrong.'),
            );
          },
        );
      },
    );
  }
}
