import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:http_mock_adapter/src/handlers/request_handler.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/constants/enum.dart';
import 'package:pma/models/member.dart';
import 'package:pma/models/task.dart';
import 'package:pma/models/user.dart';
import 'package:pma/module/tasks/bloc/tasks_bloc.dart';
import 'package:pma/module/tasks/tasks_repository.dart';
import 'package:pma/utils/network_exceptions.dart';

void main() {
  group('Tasks Bloc', () {
    late Dio dio;
    late DioAdapter dioAdapter;
    late TasksBloc taskBloc;
    const int taskId = 1;
    const int projectId = 1;
    const String fetchTasksUrl = '$tasksEndpoint/project/$projectId';
    const String deleteTaskUrl = '$tasksEndpoint/$taskId';
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
    final List<dynamic> taskData = <dynamic>[task.toJson()];

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
      taskBloc = TasksBloc(
        tasksRepository: TasksRepository(
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
      'Fetch Tasks',
      () {
        blocTest<TasksBloc, TasksState>(
          'Success',
          setUp: () {
            return dioAdapter.onGet(
              fetchTasksUrl,
              (MockServer request) => request.reply(200, taskData),
            );
          },
          build: () => taskBloc,
          act: (TasksBloc bloc) => bloc.add(
            const TasksEvent.fetchTasks(projectId: projectId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <TasksState>[
            const TasksState.loadInProgress(),
            TasksState.fetchTasksSuccess(
              tasks: <Task>[task],
            ),
          ],
        );

        blocTest<TasksBloc, TasksState>(
          'Failure',
          setUp: () {
            return dioAdapter.onGet(
              fetchTasksUrl,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => taskBloc,
          act: (TasksBloc bloc) => bloc.add(
            const TasksEvent.fetchTasks(projectId: projectId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <TasksState>[
            const TasksState.loadInProgress(),
            const TasksState.fetchTasksFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );

    group(
      'Delete Task',
      () {
        blocTest<TasksBloc, TasksState>(
          'Success',
          setUp: () {
            return dioAdapter.onDelete(
              deleteTaskUrl,
              (MockServer request) => request.reply(204, null),
            );
          },
          build: () => taskBloc,
          act: (TasksBloc bloc) => bloc.add(
            const TasksEvent.deleteTask(taskId: taskId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <TasksState>[
            const TasksState.loadInProgress(),
            const TasksState.deleteTaskSuccess(),
          ],
        );

        blocTest<TasksBloc, TasksState>(
          'Failure',
          setUp: () {
            return dioAdapter.onDelete(
              deleteTaskUrl,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => taskBloc,
          act: (TasksBloc bloc) => bloc.add(
            const TasksEvent.deleteTask(taskId: taskId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <TasksState>[
            const TasksState.loadInProgress(),
            const TasksState.deleteTaskFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );
  });
}
