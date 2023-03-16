import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:http_mock_adapter/src/handlers/request_handler.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/project.dart';
import 'package:pma/module/home/projects_repository.dart';
import 'package:pma/module/invited_projects/bloc/invited_projects_bloc.dart';
import 'package:pma/utils/network_exceptions.dart';

void main() {
  group('Invited Projects Bloc', () {
    late Dio dio;
    late DioAdapter dioAdapter;
    late InvitedProjectsBloc invitedProjectsBloc;
    const int projectId = 1;
    const int userId = 1;
    const String invitedProjectsUrl = invitedProjectsEndpoint;
    final Project project = Project(
      id: projectId,
      title: 'title',
      createdBy: userId,
      createdAt: '2023-03-16T02:51:10.577757+05:30',
    );
    final List<dynamic> projectsData = <dynamic>[project.toJson()];

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
      invitedProjectsBloc = InvitedProjectsBloc(
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
      'Invited Projects',
      () {
        blocTest<InvitedProjectsBloc, InvitedProjectsState>(
          'Success',
          setUp: () {
            return dioAdapter.onGet(
              invitedProjectsUrl,
              (MockServer request) => request.reply(200, projectsData),
            );
          },
          build: () => invitedProjectsBloc,
          act: (InvitedProjectsBloc bloc) => bloc.add(
            const InvitedProjectsEvent.fetchInvitedProjects(),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <InvitedProjectsState>[
            const InvitedProjectsState.loadInProgress(),
            InvitedProjectsState.fetchInvitedProjectsSuccess(
                projects: <Project>[project]),
          ],
        );

        blocTest<InvitedProjectsBloc, InvitedProjectsState>(
          'Failure',
          setUp: () {
            return dioAdapter.onGet(
              invitedProjectsUrl,
              (MockServer request) => request.reply(500, null),
            );
          },
          build: () => invitedProjectsBloc,
          act: (InvitedProjectsBloc bloc) => bloc.add(
            const InvitedProjectsEvent.fetchInvitedProjects(),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <InvitedProjectsState>[
            const InvitedProjectsState.loadInProgress(),
            const InvitedProjectsState.fetchInvitedProjectsFailure(
              error: NetworkExceptions.internalServerError(),
            ),
          ],
        );
      },
    );
  });
}
