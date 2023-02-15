import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pma/models/document.dart';
import 'package:pma/models/note.dart';
import 'package:pma/models/task.dart';
import 'package:pma/module/task/bloc/task_bloc.dart';
import 'package:pma/module/task/task_repository.dart';
import 'package:pma/utils/dio_client.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({
    required this.taskId,
    super.key,
  });

  final String taskId;

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<TaskBloc>(
      create: (BuildContext context) => TaskBloc(
        taskRepository: TaskRepository(
          dioClient: context.read<DioClient>(),
        ),
      ),
      child: BlocConsumer<TaskBloc, TaskState>(
        listener: (BuildContext context, TaskState state) {
          state.maybeWhen(
            fetchTaskSuccess: (Task task) {
              context.read<TaskBloc>().add(
                    TaskEvent.fetchAttachedNotes(
                      noteIds: task.notes,
                    ),
                  );
              context.read<TaskBloc>().add(
                    TaskEvent.fetchAttachedDocuments(
                      documentIds: task.documents,
                    ),
                  );
            },
            orElse: () => null,
          );
        },
        buildWhen: (TaskState previous, TaskState current) {
          return current.maybeWhen(
            initial: () => true,
            loadInProgress: () => true,
            fetchTaskSuccess: (Task task) => true,
            fetchTaskFailure: () => true,
            orElse: () => false,
          );
        },
        builder: (BuildContext context, TaskState state) {
          return state.maybeWhen(
            initial: () {
              context.read<TaskBloc>().add(
                    TaskEvent.fetchTask(
                      taskId: int.parse(widget.taskId),
                    ),
                  );
              return const CircularProgressIndicator();
            },
            loadInProgress: () {
              return const CircularProgressIndicator();
            },
            fetchTaskSuccess: (Task task) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Task Detail'),
                ),
                body: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('task id: ${task.id}'),
                        Text(task.title),
                        const Text('Created At'),
                        Text(task.createdAt),
                        const SizedBox(
                          height: 20,
                        ),
                        _buildNotesAttached(),
                        _buildDocumentsAttached(),
                      ],
                    ),
                  ),
                ),
              );
            },
            fetchTaskFailure: () {
              return const Center(
                child: Text('Something went wrong.'),
              );
            },
            orElse: () {
              return const SizedBox();
            },
          );
        },
      ),
    );
  }

  Column _buildNotesAttached() {
    return Column(
      children: <Widget>[
        ListTile(
          leading: const Icon(
            Icons.note_alt_rounded,
          ),
          title: const Text('Notes Attached'),
          trailing: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
          ),
        ),
        BlocBuilder<TaskBloc, TaskState>(
          buildWhen: (TaskState previous, TaskState current) {
            return current.maybeWhen(
              fetchAttachedNotesLoading: () => true,
              fetchAttachedNotesSuccess: (List<Note> notes) => true,
              fetchAttachedNotesFailure: () => true,
              orElse: () => false,
            );
          },
          builder: (BuildContext context, TaskState state) {
            return state.maybeWhen(
              fetchAttachedNotesLoading: () {
                return const CircularProgressIndicator();
              },
              fetchAttachedNotesSuccess: (List<Note> notes) {
                return _buildNotes(notes, context);
              },
              fetchAttachedNotesFailure: () {
                return const Text('Something went wrong!');
              },
              orElse: () {
                return const SizedBox();
              },
            );
          },
        ),
      ],
    );
  }

  Padding _buildNotes(List<Note> notes, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          final List<Note> updatedNotes = <Note>[];
          for (int i = 0; i < notes.length; i++) {
            Note note = notes[i];
            if (i == index) {
              note = notes[index].copyWith(isExpanded: !isExpanded);
            }
            updatedNotes.add(note);
          }
          context.read<TaskBloc>().add(
                TaskEvent.expandTask(
                  notes: updatedNotes,
                ),
              );
        },
        children: notes.map<ExpansionPanel>(
          (Note note) {
            return _buildNote(note);
          },
        ).toList(),
      ),
    );
  }

  ExpansionPanel _buildNote(Note note) {
    return ExpansionPanel(
      headerBuilder: (BuildContext context, bool isExpanded) {
        return ListTile(
          title: Text(note.title),
        );
      },
      body: ListTile(
        title: Text(note.contentPlainText ?? ''),
        subtitle: const Text(
          'To delete this panel, tap the trash can icon',
        ),
        trailing: const Icon(Icons.delete),
        onTap: () {},
      ),
      isExpanded: note.isExpanded,
    );
  }

  Column _buildDocumentsAttached() {
    return Column(
      children: <Widget>[
        ListTile(
          leading: const Icon(
            Icons.edit_document,
          ),
          title: const Text('Documents Attached'),
          trailing: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
          ),
        ),
        BlocBuilder<TaskBloc, TaskState>(
          buildWhen: (TaskState previous, TaskState current) {
            return current.maybeWhen(
              fetchAttachedDocumentsLoading: () => true,
              fetchAttachedDocumentsSuccess: (List<Document> documents) => true,
              fetchAttachedDocumentsFailure: () => true,
              orElse: () => false,
            );
          },
          builder: (BuildContext context, TaskState state) {
            return state.maybeWhen(
              fetchAttachedDocumentsLoading: () {
                return const CircularProgressIndicator();
              },
              fetchAttachedDocumentsSuccess: (List<Document> documents) {
                return _buildDocuments(documents, context);
              },
              fetchAttachedDocumentsFailure: () {
                return const Text('Something went wrong!');
              },
              orElse: () {
                return const SizedBox();
              },
            );
          },
        ),
      ],
    );
  }

  Padding _buildDocuments(List<Document> documents, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          final List<Document> updatedNotes = <Document>[];
          for (int i = 0; i < documents.length; i++) {
            Document note = documents[i];
            if (i == index) {
              note = documents[index].copyWith(isExpanded: !isExpanded);
            }
            updatedNotes.add(note);
          }
          context.read<TaskBloc>().add(
                TaskEvent.expandDocument(
                  documents: updatedNotes,
                ),
              );
        },
        children: documents.map<ExpansionPanel>(
          (Document document) {
            return _buildDocument(document);
          },
        ).toList(),
      ),
    );
  }

  ExpansionPanel _buildDocument(Document document) {
    return ExpansionPanel(
      headerBuilder: (BuildContext context, bool isExpanded) {
        return ListTile(
          title: Text(document.title),
        );
      },
      body: ListTile(
        title: Text(document.content ?? ''),
        subtitle: const Text(
          'To delete this panel, tap the trash can icon',
        ),
        trailing: const Icon(Icons.delete),
        onTap: () {},
      ),
      isExpanded: document.isExpanded,
    );
  }

  // void _showAttachedTasks(BuildContext context, Task task) {
  //   showModalBottomSheet<void>(
  //     context: context,
  //     backgroundColor: Colors.transparent,
  //     isScrollControlled: true,
  //     builder: (BuildContext ctx) {
  //       return BlocBuilder<TaskBloc, TaskState>(
  //         bloc: context.read<TaskBloc>()
  //           ..add(
  //             TaskEvent.fetchAttachedNotes(
  //               noteIds: task.notes,
  //             ),
  //           ),
  //         buildWhen: (TaskState previous, TaskState current) {
  //           return current.maybeWhen(
  //             fetchAttachedNotesLoading: () => true,
  //             fetchAttachedNotesSuccess: (List<Note> notes) => true,
  //             fetchAttachedNotesFailure: () => true,
  //             orElse: () => false,
  //           );
  //         },
  //         builder: (BuildContext ctx, TaskState state) {
  //           return state.maybeWhen(
  //             fetchAttachedNotesLoading: () {
  //               return const CircularProgressIndicator();
  //             },
  //             fetchAttachedNotesSuccess: (List<Note> notes) {
  //               return ConstrainedBox(
  //                 constraints: BoxConstraints(
  //                   maxHeight: MediaQuery.of(context).size.height / 1.2,
  //                 ),
  //                 child: Container(
  //                   decoration: const BoxDecoration(
  //                     borderRadius: BorderRadius.only(
  //                       topLeft: Radius.circular(16),
  //                       topRight: Radius.circular(16),
  //                     ),
  //                     color: Colors.white,
  //                   ),
  //                   child: Column(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: <Widget>[
  //                       Align(
  //                         alignment: Alignment.topRight,
  //                         child: IconButton(
  //                           onPressed: () {
  //                             Navigator.pop(context);
  //                           },
  //                           icon: const Icon(
  //                             Icons.close_rounded,
  //                           ),
  //                         ),
  //                       ),
  //                       ExpansionPanelList(
  //                         expansionCallback: (int index, bool isExpanded) {
  //                           final List<Note> updatedNotes = <Note>[];
  //                           for (int i = 0; i < notes.length; i++) {
  //                             Note note = notes[i];
  //                             if (i == index) {
  //                               note = notes[index]
  //                                   .copyWith(isExpanded: !isExpanded);
  //                             }
  //                             updatedNotes.add(note);
  //                           }
  //                           context.read<TaskBloc>().add(
  //                                 TaskEvent.expandTask(
  //                                   notes: updatedNotes,
  //                                 ),
  //                               );
  //                         },
  //                         children: notes.map<ExpansionPanel>((Note note) {
  //                           return ExpansionPanel(
  //                             headerBuilder:
  //                                 (BuildContext context, bool isExpanded) {
  //                               return ListTile(
  //                                 title: Text(note.title),
  //                               );
  //                             },
  //                             body: Column(
  //                               children: [
  //                                 ListTile(
  //                                   title: Text(note.description ?? ''),
  //                                   subtitle: const Text(
  //                                     'To delete this panel, tap the trash can icon',
  //                                   ),
  //                                   trailing: const Icon(Icons.delete),
  //                                   onTap: () {
  //                                     setState(
  //                                       () {
  //                                         notes.removeWhere(
  //                                             (Note currentItem) =>
  //                                                 note == currentItem);
  //                                       },
  //                                     );
  //                                   },
  //                                 ),
  //                                 ListTile(
  //                                   title: Text(note.description ?? ''),
  //                                   subtitle: const Text(
  //                                     'To delete this panel, tap the trash can icon',
  //                                   ),
  //                                   trailing: const Icon(Icons.delete),
  //                                   onTap: () {
  //                                     setState(
  //                                       () {
  //                                         notes.removeWhere(
  //                                             (Note currentItem) =>
  //                                                 note == currentItem);
  //                                       },
  //                                     );
  //                                   },
  //                                 ),
  //                               ],
  //                             ),
  //                             isExpanded: note.isExpanded,
  //                           );
  //                         }).toList(),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               );
  //             },
  //             fetchAttachedNotesFailure: () {
  //               return const Text('Something went wrong!');
  //             },
  //             orElse: () {
  //               return const SizedBox();
  //             },
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
}
