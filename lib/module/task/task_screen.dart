import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:go_router_flow/go_router_flow.dart';
import 'package:intl/intl.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/extentions/extensions.dart';
import 'package:pma/models/attach_document.dart';
import 'package:pma/models/attach_note.dart';
import 'package:pma/models/document.dart';
import 'package:pma/models/member.dart';
import 'package:pma/models/note.dart';
import 'package:pma/models/task.dart';
import 'package:pma/module/task/bloc/task_bloc.dart';
import 'package:pma/module/task/task_repository.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';
import 'package:pma/widgets/input_field.dart';
import 'package:pma/widgets/pma_alert_dialog.dart';
import 'package:pma/widgets/snackbar.dart';
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
  final TextEditingController _taskTitleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return BlocProvider<TaskBloc>(
      create: (BuildContext context) => TaskBloc(
        taskRepository: TaskRepository(
          dioConfig: context.read<DioConfig>(),
          dio: context.read<Dio>(),
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
            updateTaskFailure: (NetworkExceptions error) async {
              pmaAlertDialog(
                context: context,
                theme: theme,
                error: 'Could not update task successfully. Please try again.',
              );
            },
            deleteTaskSuccess: () {
              showSnackBar(
                context: context,
                theme: theme,
                message: 'Task successfully deleted',
              );
              context.pop();
            },
            deleteTaskFailure: (NetworkExceptions error) {
              pmaAlertDialog(
                context: context,
                theme: theme,
                error:
                    'Could not delete a task successfully. Please try again.',
              );
            },
            removeMemberSuccess: () {
              context.read<TaskBloc>().add(
                    TaskEvent.fetchTask(
                      taskId: int.parse(widget.taskId),
                    ),
                  );
            },
            removeMemberFailure: (NetworkExceptions error) {
              pmaAlertDialog(
                context: context,
                theme: theme,
                error:
                    'Could not invite members successfully. Please try again.',
              );
            },
            attachNotesSuccess: () {
              context.read<TaskBloc>().add(
                    TaskEvent.fetchTask(
                      taskId: int.parse(widget.taskId),
                    ),
                  );
            },
            removeAttachedNoteSuccess: () {
              context.read<TaskBloc>().add(
                    TaskEvent.fetchTask(
                      taskId: int.parse(widget.taskId),
                    ),
                  );
            },
            removeAttachedNoteFailure: (NetworkExceptions error) {
              pmaAlertDialog(
                context: context,
                theme: theme,
                error:
                    'Could not remove note attached successfully. Please try again.',
              );
            },
            attachDocumentsSuccess: () {
              context.read<TaskBloc>().add(
                    TaskEvent.fetchTask(
                      taskId: int.parse(widget.taskId),
                    ),
                  );
            },
            removeAttachedDocumentSuccess: () {
              context.read<TaskBloc>().add(
                    TaskEvent.fetchTask(
                      taskId: int.parse(widget.taskId),
                    ),
                  );
            },
            removeAttachedDocumentFailure: (NetworkExceptions error) {
              pmaAlertDialog(
                context: context,
                theme: theme,
                error:
                    'Could not remove document attached successfully. Please try again.',
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
            fetchTaskFailure: (NetworkExceptions error) => true,
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
                  automaticallyImplyLeading: false,
                  leading: BackButton(
                    onPressed: () {
                      context.pop();
                    },
                  ),
                  actions: task.currentUserRole == MemberRole.guest.index + 1
                      ? null
                      : <Widget>[
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
                          _buildTitle(task, theme),
                          const SizedBox(height: 16),
                          _buildDescription(
                            theme: theme,
                            isEdit: task.isEdit,
                          ),
                          const SizedBox(height: 32),
                          if (!task.isEdit)
                            _buildDetails(
                              context: context,
                              theme: theme,
                              task: task,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            fetchTaskFailure: (NetworkExceptions error) {
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

  InputField _buildTitle(Task task, ThemeData theme) {
    return InputField(
      controller: _taskTitleController..text = task.title,
      isEnabled: task.isEdit,
      hintText: 'Title',
      borderType: task.isEdit
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

  Widget _buildDetails({
    required BuildContext context,
    required ThemeData theme,
    required Task task,
  }) {
    final bool isGuest = task.currentUserRole == MemberRole.guest.index + 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildTaskStatus(
          theme: theme,
          task: task,
          context: context,
        ),
        const SizedBox(height: 16),
        _buildInfoItem(
          theme: theme,
          title: 'Created By',
          info: task.owner.username,
        ),
        const SizedBox(height: 16),
        _buildInfoItem(
          theme: theme,
          title: 'Created At',
          info: _dateTime(task.createdAt),
        ),
        const SizedBox(height: 10),
        const Divider(),
        const SizedBox(height: 10),
        _buildMembers(
          context: context,
          theme: theme,
          task: task,
        ),
        const SizedBox(height: 10),
        const Divider(),
        const SizedBox(height: 10),
        _buildNotesAttached(
          context: context,
          theme: theme,
          isGuest: isGuest,
        ),
        const SizedBox(height: 10),
        const Divider(),
        const SizedBox(height: 10),
        _buildDocumentsAttached(
          context: context,
          theme: theme,
          isGuest: isGuest,
        ),
      ],
    );
  }

  String _dateTime(String timestamp) {
    final DateTime datetime = DateTime.parse(timestamp).toLocal();
    return DateFormat('EEEE MMM d, y h:mm a ').format(datetime) +
        datetime.timeZoneName;
  }

  Widget _buildMembers({
    required BuildContext context,
    required ThemeData theme,
    required Task task,
  }) {
    final bool isGuest = task.currentUserRole == MemberRole.guest.index + 1;
    return Column(
      children: <Widget>[
        _buildMembersTitle(
          theme: theme,
          context: context,
          isGuest: isGuest,
        ),
        _buildMembersList(
          context: context,
          theme: theme,
          task: task,
          isGuest: isGuest,
        ),
      ],
    );
  }

  Widget _buildMembersTitle({
    required ThemeData theme,
    required BuildContext context,
    required bool isGuest,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            'Members',
            style: theme.textTheme.bodyMedium,
          ),
        ),
        if (!isGuest)
          TextButton.icon(
            onPressed: () {
              context.goNamed(
                RouteConstants.assignTask,
                params: <String, String>{
                  'taskId': widget.taskId,
                  'projectId': widget.projectId,
                },
              );
            },
            icon: Icon(
              Icons.add,
              color: theme.colorScheme.outline,
            ),
            label: Text(
              'Add',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMembersList({
    required BuildContext context,
    required ThemeData theme,
    required Task task,
    required bool isGuest,
  }) {
    if (task.members.isEmpty) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Not assigned to anyone yet.',
          style: theme.textTheme.bodyLarge,
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: task.members.length,
      itemBuilder: (BuildContext context, int index) {
        final Member member = task.members[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.outline,
            child: Icon(
              Icons.person_outline_rounded,
              color: theme.colorScheme.background,
            ),
          ),
          title: Text(member.user.username),
          subtitle: Text(MemberRole.values[member.role - 1].title),
          trailing: !isGuest
              ? IconButton(
                  onPressed: () {
                    context.read<TaskBloc>().add(
                          TaskEvent.removeMember(
                            taskId: task.id,
                            projectId: task.projectId,
                            userId: member.userId,
                          ),
                        );
                  },
                  icon: Icon(
                    Icons.cancel_rounded,
                    color: theme.colorScheme.error,
                  ),
                )
              : null,
        );
      },
    );
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

  Widget _buildTaskStatus({
    required BuildContext context,
    required ThemeData theme,
    required Task task,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.outline,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: DropdownButton<TaskStatus>(
        isDense: true,
        dropdownColor: theme.colorScheme.outline,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        value: TaskStatus.values[task.status - 1],
        onChanged: (TaskStatus? value) {
          if (value != null) {
            context.read<TaskBloc>().add(
                  TaskEvent.updateTask(
                    task: task.copyWith(
                      status: value.index + 1,
                    ),
                  ),
                );
          }
        },
        items: <DropdownMenuItem<TaskStatus>>[
          DropdownMenuItem<TaskStatus>(
            value: TaskStatus.todo,
            child: Text(
              TaskStatus.todo.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.background,
              ),
            ),
          ),
          DropdownMenuItem<TaskStatus>(
            value: TaskStatus.inProgress,
            child: Text(
              TaskStatus.inProgress.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.background,
              ),
            ),
          ),
          DropdownMenuItem<TaskStatus>(
            value: TaskStatus.completed,
            child: Text(
              TaskStatus.completed.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.background,
              ),
            ),
          ),
          DropdownMenuItem<TaskStatus>(
            value: TaskStatus.qa,
            child: Text(
              TaskStatus.qa.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.background,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required ThemeData theme,
    required Task task,
  }) {
    if (task.isEdit) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: <Widget>[
            TextButton(
              onPressed: () {
                context.read<TaskBloc>().add(
                      TaskEvent.updateTask(
                        task: task.copyWith(
                          title: _taskTitleController.text.trim(),
                          description: _controller.document.toDelta().toJson(),
                          descriptionPlainText:
                              _controller.document.toPlainText(),
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
                context.read<TaskBloc>().add(
                      TaskEvent.editTask(
                        task: task.copyWith(
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

  Column _buildNotesAttached({
    required BuildContext context,
    required ThemeData theme,
    required bool isGuest,
  }) {
    return Column(
      children: <Widget>[
        ListTile(
          contentPadding: EdgeInsets.zero,
          minLeadingWidth: 8,
          leading: Icon(
            Icons.note_alt_rounded,
            color: theme.colorScheme.outline,
          ),
          title: Text(
            'Notes Attached',
            style: theme.textTheme.titleMedium,
          ),
          trailing: isGuest
              ? null
              : IconButton(
                  onPressed: () {
                    _buildNotesBottomSheet(
                      context: context,
                      theme: theme,
                    );
                  },
                  icon: Icon(
                    Icons.add,
                    color: theme.colorScheme.outline,
                  ),
                ),
        ),
        BlocBuilder<TaskBloc, TaskState>(
          buildWhen: (TaskState previous, TaskState current) {
            return current.maybeWhen(
              fetchAttachedNotesLoading: () => true,
              fetchAttachedNotesSuccess: (List<Note> notes) => true,
              fetchAttachedNotesFailure: (NetworkExceptions error) => true,
              orElse: () => false,
            );
          },
          builder: (BuildContext context, TaskState state) {
            return state.maybeWhen(
              fetchAttachedNotesLoading: () {
                return const CircularProgressIndicator();
              },
              fetchAttachedNotesSuccess: (List<Note> notes) {
                return _buildNotes(notes, context, theme, isGuest);
              },
              fetchAttachedNotesFailure: (NetworkExceptions error) {
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

  Future<void> _buildNotesBottomSheet({
    required BuildContext context,
    required ThemeData theme,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        return BlocConsumer<TaskBloc, TaskState>(
          bloc: context.read<TaskBloc>()
            ..add(
              TaskEvent.fetchProjectNotes(
                taskId: int.parse(widget.taskId),
                projectId: int.parse(widget.projectId),
              ),
            ),
          listener: (BuildContext context, TaskState state) {
            state.maybeWhen(
              attachNotesSuccess: () {
                Navigator.pop(ctx);
              },
              attachNotesFailure: (NetworkExceptions error) {
                pmaAlertDialog(
                  context: context,
                  theme: theme,
                  error:
                      'Could not attach note successfully. Please try again.',
                );
              },
              orElse: () => null,
            );
          },
          buildWhen: (TaskState previous, TaskState current) {
            return current.maybeWhen(
              bottomSheetLoadInProgress: () => true,
              fetchProjectNotesSuccess: (List<Note> notes) => true,
              fetchProjectNotesFailure: (NetworkExceptions error) => true,
              orElse: () => false,
            );
          },
          builder: (_, TaskState state) {
            return state.maybeWhen(
              bottomSheetLoadInProgress: () {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              fetchProjectNotesSuccess: (List<Note> notes) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height / 3,
                    maxHeight: MediaQuery.of(context).size.height / 1.2,
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      color: Colors.white,
                    ),
                    child: _buildProjectNotes(notes, theme, context),
                  ),
                );
              },
              fetchProjectNotesFailure: (NetworkExceptions error) {
                return const Center(
                  child: Text('Something went wrong.'),
                );
              },
              orElse: () => const SizedBox(),
            );
          },
        );
      },
    );
  }

  Widget _buildProjectNotes(
    List<Note> notes,
    ThemeData theme,
    BuildContext context,
  ) {
    if (notes.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'No notes to attach.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListView.separated(
          shrinkWrap: true,
          itemCount: notes.length,
          separatorBuilder: (BuildContext context, int index) {
            return const Divider(height: 1);
          },
          itemBuilder: (_, int index) {
            final Note note = notes[index];
            return ListTile(
              title: Text(
                note.title,
                style: theme.textTheme.bodyLarge,
              ),
              trailing: IconButton(
                onPressed: () {
                  context.read<TaskBloc>().add(
                        TaskEvent.selectNote(
                          index: index,
                          notes: notes,
                        ),
                      );
                },
                icon: Icon(
                  Icons.check_circle_outline_outlined,
                  color: note.isSelected ? Colors.amber : Colors.grey,
                ),
              ),
            );
          },
        ),
        _buildAttachNotesButton(
          context: context,
          theme: theme,
          notes: notes,
        ),
      ],
    );
  }

  Widget _buildAttachNotesButton({
    required BuildContext context,
    required ThemeData theme,
    required List<Note> notes,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: MaterialButton(
        onPressed: () {
          context.read<TaskBloc>().add(
                TaskEvent.attachNotes(
                  notes: notes
                      .where((Note note) => note.isSelected == true)
                      .toList(),
                  taskId: int.parse(widget.taskId),
                ),
              );
        },
        elevation: 8,
        color: theme.colorScheme.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 8,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        child: Text(
          'Attach',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.background,
          ),
        ),
      ),
    );
  }

  Widget _buildNotes(
    List<Note> notes,
    BuildContext context,
    ThemeData theme,
    bool isGuest,
  ) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(
        Radius.circular(16),
      ),
      child: ExpansionPanelList(
        expandedHeaderPadding: EdgeInsets.zero,
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
            return _buildNote(
              context: context,
              theme: theme,
              note: note,
              isGuest: isGuest,
            );
          },
        ).toList(),
      ),
    );
  }

  ExpansionPanel _buildNote({
    required BuildContext context,
    required ThemeData theme,
    required Note note,
    required bool isGuest,
  }) {
    return ExpansionPanel(
      canTapOnHeader: true,
      headerBuilder: (BuildContext context, bool isExpanded) {
        return ListTile(
          title: Text(
            note.title,
            style: theme.textTheme.bodyMedium,
          ),
        );
      },
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: const BorderRadius.all(
                  Radius.circular(8),
                ),
              ),
              child: TextEditor(
                controller: quill.QuillController(
                  selection:
                      const TextSelection(baseOffset: 0, extentOffset: 0),
                  document: quill.Document.fromJson(
                    note.content ?? <dynamic>[],
                  ),
                ),
                readOnly: true,
                showCursor: false,
                minHeight: 200,
              ),
            ),
            if (isGuest) const SizedBox(height: 8),
            if (!isGuest)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    context.read<TaskBloc>().add(
                          TaskEvent.removeAttachedNote(
                            attachNote: AttachNote(
                              taskId: int.parse(widget.taskId),
                              noteId: note.id,
                            ),
                          ),
                        );
                  },
                  child: Text(
                    'Remove',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      isExpanded: note.isExpanded,
    );
  }

  Column _buildDocumentsAttached({
    required BuildContext context,
    required ThemeData theme,
    required bool isGuest,
  }) {
    return Column(
      children: <Widget>[
        ListTile(
          contentPadding: EdgeInsets.zero,
          minLeadingWidth: 8,
          leading: Icon(
            Icons.edit_document,
            color: theme.colorScheme.outline,
          ),
          title: Text(
            'Documents Attached',
            style: theme.textTheme.titleMedium,
          ),
          trailing: isGuest
              ? null
              : IconButton(
                  onPressed: () {
                    _buildDocumentsBottomSheet(context, theme);
                  },
                  icon: Icon(
                    Icons.add,
                    color: theme.colorScheme.outline,
                  ),
                ),
        ),
        BlocBuilder<TaskBloc, TaskState>(
          buildWhen: (TaskState previous, TaskState current) {
            return current.maybeWhen(
              fetchAttachedDocumentsLoading: () => true,
              fetchAttachedDocumentsSuccess: (List<Document> documents) => true,
              fetchAttachedDocumentsFailure: (NetworkExceptions error) => true,
              orElse: () => false,
            );
          },
          builder: (BuildContext context, TaskState state) {
            return state.maybeWhen(
              fetchAttachedDocumentsLoading: () {
                return const CircularProgressIndicator();
              },
              fetchAttachedDocumentsSuccess: (List<Document> documents) {
                return _buildDocuments(documents, context, theme, isGuest);
              },
              fetchAttachedDocumentsFailure: (NetworkExceptions error) {
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

  Future<void> _buildDocumentsBottomSheet(
    BuildContext context,
    ThemeData theme,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        return BlocConsumer<TaskBloc, TaskState>(
          bloc: context.read<TaskBloc>()
            ..add(
              TaskEvent.fetchProjectDocuments(
                taskId: int.parse(widget.taskId),
                projectId: int.parse(widget.projectId),
              ),
            ),
          listener: (BuildContext context, TaskState state) {
            state.maybeWhen(
              attachDocumentsSuccess: () {
                Navigator.pop(ctx);
              },
              attachDocumentFailure: (NetworkExceptions error) {
                pmaAlertDialog(
                  context: context,
                  theme: theme,
                  error:
                      'Could not attach note successfully. Please try again.',
                );
              },
              orElse: () => null,
            );
          },
          buildWhen: (TaskState previous, TaskState current) {
            return current.maybeWhen(
              bottomSheetLoadInProgress: () => true,
              fetchProjectDocumentsSuccess: (List<Document> documents) => true,
              fetchProjectDocumentsFailure: (NetworkExceptions error) => true,
              orElse: () => false,
            );
          },
          builder: (_, TaskState state) {
            return state.maybeWhen(
              bottomSheetLoadInProgress: () {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              fetchProjectDocumentsSuccess: (List<Document> documents) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height / 3,
                    maxHeight: MediaQuery.of(context).size.height / 1.2,
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      color: Colors.white,
                    ),
                    child: _buildProjectDocuments(documents, theme, context),
                  ),
                );
              },
              fetchProjectDocumentsFailure: (NetworkExceptions error) {
                return const Center(
                  child: Text('Something went wrong.'),
                );
              },
              orElse: () => const SizedBox(),
            );
          },
        );
      },
    );
  }

  Widget _buildProjectDocuments(
    List<Document> documents,
    ThemeData theme,
    BuildContext context,
  ) {
    if (documents.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'No documents to attach.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListView.separated(
          shrinkWrap: true,
          itemCount: documents.length,
          separatorBuilder: (BuildContext context, int index) {
            return const Divider(height: 1);
          },
          itemBuilder: (_, int index) {
            final Document document = documents[index];
            return ListTile(
              title: Text(
                document.title,
                style: theme.textTheme.bodyLarge,
              ),
              trailing: IconButton(
                onPressed: () {
                  context.read<TaskBloc>().add(
                        TaskEvent.selectDocument(
                          index: index,
                          documents: documents,
                        ),
                      );
                },
                icon: Icon(
                  Icons.check_circle_outline_outlined,
                  color: document.isSelected ? Colors.amber : Colors.grey,
                ),
              ),
            );
          },
        ),
        _buildAttachDocumentsButton(
          context: context,
          theme: theme,
          documents: documents,
        ),
      ],
    );
  }

  Widget _buildAttachDocumentsButton({
    required BuildContext context,
    required ThemeData theme,
    required List<Document> documents,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: MaterialButton(
        onPressed: () {
          context.read<TaskBloc>().add(
                TaskEvent.attachDocuments(
                  documents: documents
                      .where((Document document) => document.isSelected == true)
                      .toList(),
                  taskId: int.parse(widget.taskId),
                ),
              );
        },
        elevation: 8,
        color: theme.colorScheme.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 8,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        child: Text(
          'Attach',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.background,
          ),
        ),
      ),
    );
  }

  Widget _buildDocuments(
    List<Document> documents,
    BuildContext context,
    ThemeData theme,
    bool isGuest,
  ) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(
        Radius.circular(16),
      ),
      child: ExpansionPanelList(
        expandedHeaderPadding: EdgeInsets.zero,
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
            return _buildDocument(context, theme, document, isGuest);
          },
        ).toList(),
      ),
    );
  }

  ExpansionPanel _buildDocument(
    BuildContext context,
    ThemeData theme,
    Document document,
    bool isGuest,
  ) {
    return ExpansionPanel(
      headerBuilder: (BuildContext context, bool isExpanded) {
        return ListTile(
          title: Text(
            document.title,
            style: theme.textTheme.bodyMedium,
          ),
        );
      },
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: const BorderRadius.all(
                  Radius.circular(8),
                ),
              ),
              child: TextEditor(
                controller: quill.QuillController(
                  selection:
                      const TextSelection(baseOffset: 0, extentOffset: 0),
                  document: quill.Document.fromJson(
                    document.content ?? <dynamic>[],
                  ),
                ),
                readOnly: true,
                showCursor: false,
                minHeight: 200,
              ),
            ),
            if (isGuest) const SizedBox(height: 8),
            if (!isGuest)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    context.read<TaskBloc>().add(
                          TaskEvent.removeAttachedDocument(
                            attachDocument: AttachDocument(
                              taskId: int.parse(widget.taskId),
                              documentId: document.id,
                            ),
                          ),
                        );
                  },
                  child: Text(
                    'Remove',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      isExpanded: document.isExpanded,
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
