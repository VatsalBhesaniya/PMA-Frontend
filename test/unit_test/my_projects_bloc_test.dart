import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:http_mock_adapter/src/handlers/request_handler.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/create_project.dart';
import 'package:pma/models/project.dart';
import 'package:pma/module/home/projects_repository.dart';
import 'package:pma/module/my_projects/bloc/my_projects_bloc.dart';
import 'package:pma/utils/network_exceptions.dart';

void main() {
  group('My Projects Bloc', () {
    late Dio dio;
    late DioAdapter dioAdapter;
    late MyProjectsBloc myProjectsBloc;
    const int projectId = 1;
    const int userId = 1;
    const String fetchProjectsUrl = projectsEndpoint;
    const String createProjectUrl = createProjectEndpoint;
    final Project project = Project(
      id: projectId,
      title: 'title',
      createdBy: userId,
      createdAt: '2023-03-16T02:51:10.577757+05:30',
    );
    final Map<String, dynamic> projectData = project.toJson();
    final List<dynamic> projectsData = <dynamic>[project.toJson()];
    final CreateProject createProject = CreateProject(title: 'title');

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
      myProjectsBloc = MyProjectsBloc(
        projectsRepository: ProjectsRepository(
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
      'Fetch My Projects',
      () {
        blocTest<MyProjectsBloc, MyProjectsState>(
          'Success',
          setUp: () {
            return dioAdapter.onGet(
              fetchProjectsUrl,
              (MockServer request) => request.reply(200, projectsData),
            );
          },
          build: () => myProjectsBloc,
          act: (MyProjectsBloc bloc) => bloc.add(
            const MyProjectsEvent.fetchProjects(),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <MyProjectsState>[
            const MyProjectsState.loadInProgress(),
            MyProjectsState.fetchProjectsSuccess(
              projects: <Project>[project],
            ),
          ],
        );

        blocTest<MyProjectsBloc, MyProjectsState>(
          'Failure',
          setUp: () {
            return dioAdapter.onGet(
              fetchProjectsUrl,
              (MockServer request) => request.reply(500, null),
            );
          },
          build: () => myProjectsBloc,
          act: (MyProjectsBloc bloc) => bloc.add(
            const MyProjectsEvent.fetchProjects(),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <MyProjectsState>[
            const MyProjectsState.loadInProgress(),
            const MyProjectsState.fetchProjectsFailure(
              error: NetworkExceptions.internalServerError(),
            ),
          ],
        );
      },
    );

    group(
      'Create Project',
      () {
        blocTest<MyProjectsBloc, MyProjectsState>(
          'Success',
          setUp: () {
            return dioAdapter.onPost(
              createProjectUrl,
              data: projectData,
              (MockServer request) => request.reply(201, null),
            );
          },
          build: () => myProjectsBloc,
          act: (MyProjectsBloc bloc) => bloc.add(
            MyProjectsEvent.createProject(project: createProject),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <MyProjectsState>[
            const MyProjectsState.createProjectSuccess(),
          ],
        );

        blocTest<MyProjectsBloc, MyProjectsState>(
          'Failure',
          setUp: () {
            return dioAdapter.onPost(
              createProjectUrl,
              data: projectData,
              (MockServer request) => request.reply(500, null),
            );
          },
          build: () => myProjectsBloc,
          act: (MyProjectsBloc bloc) => bloc.add(
            MyProjectsEvent.createProject(project: createProject),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <MyProjectsState>[
            const MyProjectsState.createProjectFailure(
              error: NetworkExceptions.internalServerError(),
            ),
          ],
        );
      },
    );
  });
}
