import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:go_router/go_router.dart';
import 'package:pma/config/http_client_config.dart';
import 'package:pma/models/document.dart';
import 'package:pma/models/note.dart';
import 'package:pma/models/task.dart';
import 'package:pma/module/task/bloc/task_bloc.dart';
import 'package:pma/module/task/task_repository.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';
import 'package:pma/widgets/text_editor.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({
    required this.projectId,
    required this.taskId,
    super.key,
  });

  final String projectId;
  final String taskId;

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final quill.QuillController _controller = quill.QuillController.basic();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return BlocProvider<TaskBloc>(
      create: (BuildContext context) => TaskBloc(
        taskRepository: TaskRepository(
          dioClient: context.read<DioClient>(),
          httpClient: context.read<HttpClientConfig>(),
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
            updateTaskFailure: () async {
              _showUpdateTaskFailureAlert(context, theme);
            },
            deleteTaskSuccess: () {
              context.pop();
              _showSnackBar(context: context, theme: theme);
            },
            deleteTaskFailure: (NetworkExceptions error) {
              _buildDeleteTaskFailureAlert(
                context: context,
                theme: theme,
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
            fetchTaskSuccess: (Task task) {
              if (task.description != null) {
                _controller.document =
                    quill.Document.fromJson(task.description ?? <dynamic>[]);
              }
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Task Detail'),
                  actions: <Widget>[
                    _buildActionButton(
                      context: context,
                      theme: theme,
                      task: task,
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
                          const SizedBox(height: 16),
                          Text('task id: ${task.id}'),
                          const SizedBox(height: 16),
                          Text(task.title),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              const Text('Owner'),
                              const SizedBox(width: 16),
                              Text(task.owner.username),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildDescription(
                            theme: theme,
                            isEdit: task.isEdit,
                          ),
                          const SizedBox(height: 16),
                          const Text('Created At'),
                          const SizedBox(height: 16),
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
                ),
              );
            },
            fetchTaskFailure: () {
              return const Scaffold(
                body: Center(
                  child: Text('Something went wrong.'),
                ),
              );
            },
            orElse: () {
              return const Scaffold(
                body: SizedBox(),
              );
            },
          );
        },
      ),
    );
  }

  Future<String?> _showUpdateTaskFailureAlert(
      BuildContext context, ThemeData theme) {
    return showDialog<String>(
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
  }

  Widget _buildActionButton({
    required BuildContext context,
    required ThemeData theme,
    required Task task,
  }) {
    if (task.isEdit) {
      return Row(
        children: <Widget>[
          TextButton(
            onPressed: () {
              context.read<TaskBloc>().add(
                    TaskEvent.updateTask(
                      task: task.copyWith(
                        description: _controller.document.toDelta().toJson(),
                        descriptionPlainText:
                            _controller.document.toPlainText(),
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
              context.read<TaskBloc>().add(
                    TaskEvent.editTask(
                      task: task.copyWith(
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
    return Row(
      children: <Widget>[
        IconButton(
          onPressed: () {
            _showDeleteTaskConfirmDialog(
              context: context,
              theme: theme,
              taskId: task.id,
            );
          },
          icon: const Icon(
            Icons.delete_rounded,
          ),
        ),
        IconButton(
          onPressed: () {
            context.read<TaskBloc>().add(
                  TaskEvent.editTask(
                    task: task.copyWith(
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
        title: Text(document.contentPlainText ?? ''),
        subtitle: const Text(
          'To delete this panel, tap the trash can icon',
        ),
        trailing: const Icon(Icons.delete),
        onTap: () {},
      ),
      isExpanded: document.isExpanded,
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
          'Task successfully deleted',
          textAlign: TextAlign.center,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  void _buildDeleteTaskFailureAlert({
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
            'Could not delete a task successfully. Please try again.',
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

  void _showDeleteTaskConfirmDialog({
    required BuildContext context,
    required ThemeData theme,
    required int taskId,
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
            'Are you sure you want to delete this task?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                context.read<TaskBloc>().add(
                      TaskEvent.deleteTask(taskId: taskId),
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
