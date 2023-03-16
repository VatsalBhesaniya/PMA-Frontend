import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:http_mock_adapter/src/handlers/request_handler.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/project.dart';
import 'package:pma/module/project/bloc/project_bloc.dart';
import 'package:pma/module/project/project_repository.dart';
import 'package:pma/utils/network_exceptions.dart';

void main() {
  group('Project Bloc', () {
    late Dio dio;
    late DioAdapter dioAdapter;
    late ProjectBloc projectBloc;
    const int projectId = 1;
    const int userId = 1;
    const String projectsUrl = '$projectsEndpoint/$projectId';
    final Project project = Project(
      id: 1,
      title: 'title',
      createdAt: '2023-03-16T02:51:10.577757+05:30',
      createdBy: userId,
    );
    final Map<String, dynamic> data = project.toJson();

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
      projectBloc = ProjectBloc(
        projectRepository: ProjectRepository(
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
      'Fetch Project',
      () {
        blocTest<ProjectBloc, ProjectState>(
          'Success',
          setUp: () {
            return dioAdapter.onGet(
              projectsUrl,
              (MockServer request) => request.reply(200, data),
            );
          },
          build: () => projectBloc,
          act: (ProjectBloc bloc) => bloc.add(
            const ProjectEvent.fetchProject(projectId: projectId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <ProjectState>[
            const ProjectState.loadInProgress(),
            ProjectState.fetchProjectSuccess(project: project),
          ],
        );

        blocTest<ProjectBloc, ProjectState>(
          'Failure',
          setUp: () {
            return dioAdapter.onGet(
              projectsUrl,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => projectBloc,
          act: (ProjectBloc bloc) => bloc.add(
            const ProjectEvent.fetchProject(projectId: projectId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <ProjectState>[
            const ProjectState.loadInProgress(),
            const ProjectState.fetchProjectFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );
  });
}
