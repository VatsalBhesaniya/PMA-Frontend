import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:http_mock_adapter/src/handlers/request_handler.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/constants/enum.dart';
import 'package:pma/models/attach_document.dart';
import 'package:pma/models/attach_note.dart';
import 'package:pma/models/document.dart';
import 'package:pma/models/member.dart';
import 'package:pma/models/note.dart';
import 'package:pma/models/task.dart';
import 'package:pma/models/user.dart';
import 'package:pma/module/task/bloc/task_bloc.dart';
import 'package:pma/module/task/task_repository.dart';
import 'package:pma/utils/network_exceptions.dart';

void main() {
  group('Task Bloc', () {
    late Dio dio;
    late DioAdapter dioAdapter;
    late TaskBloc taskBloc;
    const int taskId = 1;
    const int projectId = 1;
    const int noteId = 1;
    const int documentId = 1;
    const int userId = 1;
    const String tasksUrl = '$tasksEndpoint/$taskId';
    const String fetchAttachedNotesUrl =
        '$notesEndpoint/attached?noteId=$noteId&';
    const String fetchAttachedDocumentsUrl =
        '$documentsEndpoint/attached?documentId=$documentId&';
    const String removeAssignedMemberUrl =
        '$assignTasksEndpoint/$taskId/$projectId/$userId';
    const String fetchProjectNotesUrl =
        '$projectNotesEndpoint/$taskId/$projectId';
    const String fetchProjectDocumentsUrl =
        '$projectDocumentsEndpoint/$taskId/$projectId';
    final Task task = Task(
      id: taskId,
      projectId: projectId,
      title: 'title',
      createdAt: '2023-03-16T02:51:10.577757+05:30',
      members: <Member>[],
      notes: <int>[],
      documents: <int>[],
      status: TaskStatus.todo.index + 1,
      owner: User(
        id: 1,
        firstName: 'firstName',
        lastName: 'lastName',
        username: 'username',
        email: 'email',
        createdAt: '2023-03-16T02:51:10.577757+05:30',
      ),
    );
    final Map<String, dynamic> taskData = task.toJson();
    final Note note = Note(
      id: 59,
      projectId: 50,
      title: 'Test Title',
      content: <dynamic>[
        <String, dynamic>{'insert': 'Test Description'}
      ],
      contentPlainText: 'Test Description',
      createdBy: 1,
      createdAt: '2023-03-16T02:51:10.577757+05:30',
      currentUserRole: 4,
      isExpanded: false,
      isEdit: false,
      isSelected: false,
    );
    final AttachNote attachNote = AttachNote(
      taskId: taskId,
      noteId: noteId,
    );
    final AttachDocument attachDocument = AttachDocument(
      taskId: taskId,
      documentId: documentId,
    );
    final List<dynamic> notesData = <dynamic>[note.toJson()];
    final Document document = Document(
      id: 59,
      projectId: 50,
      title: 'Test Title',
      content: <dynamic>[
        <String, dynamic>{'insert': 'Test Description'}
      ],
      contentPlainText: 'Test Description',
      createdBy: 1,
      createdAt: '2023-03-16T02:51:10.577757+05:30',
      currentUserRole: 4,
      isExpanded: false,
      isEdit: false,
      isSelected: false,
    );
    final List<dynamic> documentsData = <dynamic>[document.toJson()];

    setUp(() {
      dio = Dio(
        BaseOptions(
          baseUrl: iosBaseUrl,
          connectTimeout: const Duration(minutes: 1),
          receiveTimeout: const Duration(minutes: 1),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8'
          },
        ),
      );
      dioAdapter = DioAdapter(
        dio: dio,
        matcher: const UrlRequestMatcher(),
      );
      dio.httpClientAdapter = dioAdapter;
      taskBloc = TaskBloc(
        taskRepository: TaskRepository(
          dio: dio,
          dioConfig: DioConfig(
            baseUrl: iosBaseUrl,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'authorization': 'token'
            },
          ),
        ),
      );
    });

    group(
      'Fetch Task',
      () {
        blocTest<TaskBloc, TaskState>(
          'Success',
          setUp: () {
            return dioAdapter.onGet(
              tasksUrl,
              (MockServer request) => request.reply(200, taskData),
            );
          },
          build: () => taskBloc,
          act: (TaskBloc bloc) => bloc.add(
            const TaskEvent.fetchTask(taskId: taskId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <TaskState>[
            const TaskState.loadInProgress(),
            TaskState.fetchTaskSuccess(
              task: task,
            ),
          ],
        );

        blocTest<TaskBloc, TaskState>(
          'Failure',
          setUp: () {
            return dioAdapter.onGet(
              tasksUrl,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => taskBloc,
          act: (TaskBloc bloc) => bloc.add(
            const TaskEvent.fetchTask(taskId: taskId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <TaskState>[
            const TaskState.loadInProgress(),
            const TaskState.fetchTaskFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );

    group(
      'Update Task',
      () {
        blocTest<TaskBloc, TaskState>(
          'Success',
          setUp: () {
            return dioAdapter.onPut(
              tasksUrl,
              (MockServer request) => request.reply(200, taskData),
            );
          },
          build: () => taskBloc,
          act: (TaskBloc bloc) => bloc.add(
            TaskEvent.updateTask(task: task),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <TaskState>[
            const TaskState.loadInProgress(),
            TaskState.fetchTaskSuccess(
              task: task,
            ),
          ],
        );

        blocTest<TaskBloc, TaskState>(
          'Failure',
          setUp: () {
            return dioAdapter.onPut(
              tasksUrl,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => taskBloc,
          act: (TaskBloc bloc) => bloc.add(
            TaskEvent.updateTask(task: task),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <TaskState>[
            const TaskState.loadInProgress(),
            const TaskState.updateTaskFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );

    group(
      'Delete Task',
      () {
        blocTest<TaskBloc, TaskState>(
          'Success',
          setUp: () {
            return dioAdapter.onDelete(
              tasksUrl,
              (MockServer request) => request.reply(204, null),
            );
          },
          build: () => taskBloc,
          act: (TaskBloc bloc) => bloc.add(
            const TaskEvent.deleteTask(taskId: taskId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <TaskState>[
            const TaskState.loadInProgress(),
            const TaskState.deleteTaskSuccess(),
          ],
        );

        blocTest<TaskBloc, TaskState>(
          'Failure',
          setUp: () {
            return dioAdapter.onDelete(
              tasksUrl,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => taskBloc,
          act: (TaskBloc bloc) => bloc.add(
            const TaskEvent.deleteTask(taskId: taskId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <TaskState>[
            const TaskState.loadInProgress(),
            const TaskState.deleteTaskFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );

    group(
      'Fetch Attached Notes',
      () {
        blocTest<TaskBloc, TaskState>(
          'Success',
          setUp: () {
            return dioAdapter.onGet(
              fetchAttachedNotesUrl,
              (MockServer request) => request.reply(200, notesData),
            );
          },
          build: () => taskBloc,
          act: (TaskBloc bloc) => bloc.add(
            const TaskEvent.fetchAttachedNotes(noteIds: <int>[noteId]),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <TaskState>[
            const TaskState.fetchAttachedNotesLoading(),
            TaskState.fetchAttachedNotesSuccess(
              notes: <Note>[note],
            ),
          ],
        );

        blocTest<TaskBloc, TaskState>(
          'Failure',
          setUp: () {
            return dioAdapter.onGet(
              fetchAttachedNotesUrl,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => taskBloc,
          act: (TaskBloc bloc) => bloc.add(
            const TaskEvent.fetchAttachedNotes(noteIds: <int>[noteId]),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <TaskState>[
            const TaskState.fetchAttachedNotesLoading(),
            const TaskState.fetchAttachedNotesFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );

    group(
      'Fetch Attached Documents',
      () {
        blocTest<TaskBloc, TaskState>(
          'Success',
          setUp: () {
            return dioAdapter.onGet(
              fetchAttachedDocumentsUrl,
              (MockServer request) => request.reply(200, documentsData),
            );
          },
          build: () => taskBloc,
          act: (TaskBloc bloc) => bloc.add(
            const TaskEvent.fetchAttachedDocuments(
                documentIds: <int>[documentId]),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <TaskState>[
            const TaskState.fetchAttachedDocumentsLoading(),
            TaskState.fetchAttachedDocumentsSuccess(
              documents: <Document>[document],
            ),
          ],
        );

        blocTest<TaskBloc, TaskState>(
          'Failure',
          setUp: () {
            return dioAdapter.onGet(
              fetchAttachedDocumentsUrl,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => taskBloc,
          act: (TaskBloc bloc) => bloc.add(
            const TaskEvent.fetchAttachedDocuments(
                documentIds: <int>[documentId]),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <TaskState>[
            const TaskState.fetchAttachedDocumentsLoading(),
            const TaskState.fetchAttachedDocumentsFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );

    group(
      'Remove Assigned Member',
      () {
        blocTest<TaskBloc, TaskState>(
          'Success',
          setUp: () {
            return dioAdapter.onDelete(
              removeAssignedMemberUrl,
              (MockServer request) => request.reply(204, null),
            );
          },
          build: () => taskBloc,
          act: (TaskBloc bloc) => bloc.add(
            const TaskEvent.removeMember(
              projectId: projectId,
              taskId: taskId,
              userId: userId,
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <TaskState>[
            const TaskState.loadInProgress(),
            const TaskState.removeMemberSuccess(),
          ],
        );

        blocTest<TaskBloc, TaskState>(
          'Failure',
          setUp: () {
            return dioAdapter.onDelete(
              removeAssignedMemberUrl,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => taskBloc,
          act: (TaskBloc bloc) => bloc.add(
            const TaskEvent.removeMember(
              projectId: projectId,
              taskId: taskId,
              userId: userId,
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <TaskState>[
            const TaskState.loadInProgress(),
            const TaskState.removeMemberFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );

    group(
      'Fetch Project Notes',
      () {
        blocTest<TaskBloc, TaskState>(
          'Success',
          setUp: () {
            return dioAdapter.onGet(
              fetchProjectNotesUrl,
              (MockServer request) => request.reply(200, notesData),
            );
          },
          build: () => taskBloc,
          act: (TaskBloc bloc) => bloc.add(
            const TaskEvent.fetchProjectNotes(
              projectId: projectId,
              taskId: taskId,
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <TaskState>[
            const TaskState.bottomSheetLoadInProgress(),
            TaskState.fetchProjectNotesSuccess(
              notes: <Note>[note],
            ),
          ],
        );

        blocTest<TaskBloc, TaskState>(
          'Failure',
          setUp: () {
            return dioAdapter.onDelete(
              fetchProjectNotesUrl,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => taskBloc,
          act: (TaskBloc bloc) => bloc.add(
            const TaskEvent.fetchProjectNotes(
              projectId: projectId,
              taskId: taskId,
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <TaskState>[
            const TaskState.bottomSheetLoadInProgress(),
            const TaskState.fetchProjectNotesFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );

    group(
      'Fetch Project Documents',
      () {
        blocTest<TaskBloc, TaskState>(
          'Success',
          setUp: () {
            return dioAdapter.onGet(
              fetchProjectDocumentsUrl,
              (MockServer request) => request.reply(200, documentsData),
            );
          },
          build: () => taskBloc,
          act: (TaskBloc bloc) => bloc.add(
            const TaskEvent.fetchProjectDocuments(
              projectId: projectId,
              taskId: taskId,
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <TaskState>[
            const TaskState.bottomSheetLoadInProgress(),
            TaskState.fetchProjectDocumentsSuccess(
              documents: <Document>[document],
            ),
          ],
        );

        blocTest<TaskBloc, TaskState>(
          'Failure',
          setUp: () {
            return dioAdapter.onDelete(
              fetchProjectDocumentsUrl,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => taskBloc,
          act: (TaskBloc bloc) => bloc.add(
            const TaskEvent.fetchProjectDocuments(
              projectId: projectId,
              taskId: taskId,
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <TaskState>[
            const TaskState.bottomSheetLoadInProgress(),
            const TaskState.fetchProjectDocumentsFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );

    group(
      'Attach Notes',
      () {
        blocTest<TaskBloc, TaskState>(
          'Success',
          setUp: () {
            return dioAdapter.onPost(
              attachNotesEndpoint,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => taskBloc,
          act: (TaskBloc bloc) => bloc.add(
            TaskEvent.attachNotes(
              taskId: taskId,
              notes: <Note>[note],
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <TaskState>[
            const TaskState.attachNotesSuccess(),
          ],
        );

        blocTest<TaskBloc, TaskState>(
          'Failure',
          setUp: () {
            return dioAdapter.onDelete(
              attachNotesEndpoint,
              (MockServer request) => request.reply(500, null),
            );
          },
          build: () => taskBloc,
          act: (TaskBloc bloc) => bloc.add(
            TaskEvent.attachNotes(
              taskId: taskId,
              notes: <Note>[note],
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <TaskState>[
            const TaskState.attachNotesFailure(
              error: NetworkExceptions.internalServerError(),
            ),
          ],
        );
      },
    );

    group(
      'Attach Documents',
      () {
        blocTest<TaskBloc, TaskState>(
          'Success',
          setUp: () {
            return dioAdapter.onPost(
              attachDocumentsEndpoint,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => taskBloc,
          act: (TaskBloc bloc) => bloc.add(
            TaskEvent.attachDocuments(
              taskId: taskId,
              documents: <Document>[document],
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <TaskState>[
            const TaskState.attachDocumentsSuccess(),
          ],
        );

        blocTest<TaskBloc, TaskState>(
          'Failure',
          setUp: () {
            return dioAdapter.onDelete(
              attachDocumentsEndpoint,
              (MockServer request) => request.reply(500, null),
            );
          },
          build: () => taskBloc,
          act: (TaskBloc bloc) => bloc.add(
            TaskEvent.attachDocuments(
              taskId: taskId,
              documents: <Document>[document],
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <TaskState>[
            const TaskState.attachDocumentFailure(
              error: NetworkExceptions.internalServerError(),
            ),
          ],
        );
      },
    );

    group(
      'Remove Attached Note',
      () {
        blocTest<TaskBloc, TaskState>(
          'Success',
          setUp: () {
            return dioAdapter.onPost(
              '$attachNotesEndpoint/$taskId/$noteId',
              (MockServer request) => request.reply(204, null),
            );
          },
          build: () => taskBloc,
          act: (TaskBloc bloc) => bloc.add(
            TaskEvent.removeAttachedNote(
              attachNote: attachNote,
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <TaskState>[
            const TaskState.removeAttachedNoteSuccess(),
          ],
        );

        blocTest<TaskBloc, TaskState>(
          'Failure',
          setUp: () {
            return dioAdapter.onDelete(
              '$attachNotesEndpoint/$taskId/$noteId',
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => taskBloc,
          act: (TaskBloc bloc) => bloc.add(
            TaskEvent.removeAttachedNote(
              attachNote: attachNote,
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <TaskState>[
            const TaskState.removeAttachedNoteFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );

    group(
      'Remove Attached Document',
      () {
        blocTest<TaskBloc, TaskState>(
          'Success',
          setUp: () {
            return dioAdapter.onPost(
              '$attachDocumentsEndpoint/$taskId/$documentId',
              (MockServer request) => request.reply(204, null),
            );
          },
          build: () => taskBloc,
          act: (TaskBloc bloc) => bloc.add(
            TaskEvent.removeAttachedDocument(
              attachDocument: attachDocument,
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <TaskState>[
            const TaskState.removeAttachedDocumentSuccess(),
          ],
        );

        blocTest<TaskBloc, TaskState>(
          'Failure',
          setUp: () {
            return dioAdapter.onDelete(
              '$attachDocumentsEndpoint/$taskId/$documentId',
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => taskBloc,
          act: (TaskBloc bloc) => bloc.add(
            TaskEvent.removeAttachedDocument(
              attachDocument: attachDocument,
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <TaskState>[
            const TaskState.removeAttachedDocumentFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );
  });
}
