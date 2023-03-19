import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:http_mock_adapter/src/handlers/request_handler.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/constants/enum.dart';
import 'package:pma/models/create_task.dart';
import 'package:pma/models/member.dart';
import 'package:pma/models/task.dart';
import 'package:pma/models/user.dart';
import 'package:pma/module/create_task/bloc/create_task_bloc.dart';
import 'package:pma/module/create_task/create_task_repository.dart';
import 'package:pma/utils/network_exceptions.dart';

void main() {
  group('Create Task Bloc', () {
    late Dio dio;
    late DioAdapter dioAdapter;
    late CreateTaskBloc createTaskBloc;
    const int taskId = 1;
    const int projectId = 1;
    const String createTaskUrl = createTasksEndpoint;
    final CreateTask createTask = CreateTask(
      projectId: projectId,
      title: 'title',
    );
    final Map<String, dynamic> createTaskData = createTask.toJson();
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
      createTaskBloc = CreateTaskBloc(
        createTaskRepository: CreateTaskRepository(
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
      'Create Task',
      () {
        blocTest<CreateTaskBloc, CreateTaskState>(
          'Success',
          setUp: () {
            return dioAdapter.onPost(
              createTaskUrl,
              data: createTaskData,
              (MockServer request) => request.reply(200, taskData),
            );
          },
          build: () => createTaskBloc,
          act: (CreateTaskBloc bloc) => bloc.add(
            CreateTaskEvent.createTask(task: createTask),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <CreateTaskState>[
            const CreateTaskState.loadInProgress(),
            CreateTaskState.createTaskSuccess(
              taskId: Task.fromJson(taskData).id,
            ),
          ],
        );

        blocTest<CreateTaskBloc, CreateTaskState>(
          'Failure',
          setUp: () {
            return dioAdapter.onPost(
              createTaskUrl,
              data: createTaskData,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => createTaskBloc,
          act: (CreateTaskBloc bloc) => bloc.add(
            CreateTaskEvent.createTask(task: createTask),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <CreateTaskState>[
            const CreateTaskState.loadInProgress(),
            const CreateTaskState.createTaskFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );
  });
}
