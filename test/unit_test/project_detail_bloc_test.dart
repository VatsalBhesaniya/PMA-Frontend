import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:http_mock_adapter/src/handlers/request_handler.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/constants/enum.dart';
import 'package:pma/models/member.dart';
import 'package:pma/models/project.dart';
import 'package:pma/models/project_detail.dart';
import 'package:pma/models/user.dart';
import 'package:pma/module/project_detail/bloc/project_detail_bloc.dart';
import 'package:pma/module/project_detail/project_detail_repository.dart';
import 'package:pma/utils/network_exceptions.dart';

void main() {
  group('Project Bloc', () {
    late Dio dio;
    late DioAdapter dioAdapter;
    late ProjectDetailBloc projectDetailBloc;
    const int projectId = 1;
    const int userId = 1;
    const String fetchProjectUrl = '$projectDetailEndpoint/$projectId';
    const String updateProjectUrl = '$projectsEndpoint/$projectId';
    const String updateProjectMemberRoleUrl = inviteMembersEndpoint;
    const String removeMemberUrl = '$membersEndpoint/$projectId/$userId';
    const String deleteProjectUrl = '$projectsEndpoint/$projectId';
    final ProjectDetail projectDetail = ProjectDetail(
      id: projectId,
      title: 'title',
      createdBy: userId,
      createdAt: '2023-03-16T02:51:10.577757+05:30',
      members: <Member>[],
    );
    final Map<String, dynamic> projectDetailData = projectDetail.toJson();
    final Project project = Project(
      id: 1,
      title: 'title',
      createdAt: '2023-03-16T02:51:10.577757+05:30',
      createdBy: userId,
    );
    final Map<String, dynamic> projectData = project.toJson();
    final Member member = Member(
      userId: userId,
      projectId: projectId,
      role: MemberRole.member.index + 1,
      createdAt: '2023-03-16T02:51:10.577757+05:30',
      user: User(
        id: userId,
        firstName: 'firstName',
        lastName: 'lastName',
        username: 'username',
        email: 'email',
        createdAt: '2023-03-16T02:51:10.577757+05:30',
      ),
    );
    final Map<String, dynamic> memberData = member.toJson()..remove('user');

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
      projectDetailBloc = ProjectDetailBloc(
        projectDetailRepository: ProjectDetailRepository(
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
      'Fetch Project Detail',
      () {
        blocTest<ProjectDetailBloc, ProjectDetailState>(
          'Success',
          setUp: () {
            return dioAdapter.onGet(
              fetchProjectUrl,
              (MockServer request) => request.reply(200, projectDetailData),
            );
          },
          build: () => projectDetailBloc,
          act: (ProjectDetailBloc bloc) => bloc.add(
            const ProjectDetailEvent.fetchProjectDetail(projectId: projectId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <ProjectDetailState>[
            const ProjectDetailState.loadInProgress(),
            ProjectDetailState.fetchProjectDetailSuccess(
              projectDetail: projectDetail,
            ),
          ],
        );

        blocTest<ProjectDetailBloc, ProjectDetailState>(
          'Failure',
          setUp: () {
            return dioAdapter.onGet(
              fetchProjectUrl,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => projectDetailBloc,
          act: (ProjectDetailBloc bloc) => bloc.add(
            const ProjectDetailEvent.fetchProjectDetail(projectId: projectId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <ProjectDetailState>[
            const ProjectDetailState.loadInProgress(),
            const ProjectDetailState.fetchProjectDetailFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );

    group(
      'Update Project Detail',
      () {
        blocTest<ProjectDetailBloc, ProjectDetailState>(
          'Success',
          setUp: () {
            return dioAdapter.onPut(
              updateProjectUrl,
              data: projectData,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => projectDetailBloc,
          act: (ProjectDetailBloc bloc) => bloc.add(
            ProjectDetailEvent.updateProjectDetail(
              projectDetail: projectDetail,
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <ProjectDetailState>[
            ProjectDetailState.fetchProjectDetailSuccess(
              projectDetail: projectDetail,
            ),
          ],
        );

        blocTest<ProjectDetailBloc, ProjectDetailState>(
          'Failure',
          setUp: () {
            return dioAdapter.onPut(
              updateProjectUrl,
              data: projectData,
              (MockServer request) => request.reply(500, null),
            );
          },
          build: () => projectDetailBloc,
          act: (ProjectDetailBloc bloc) => bloc.add(
            ProjectDetailEvent.updateProjectDetail(
              projectDetail: projectDetail,
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <ProjectDetailState>[
            const ProjectDetailState.updateProjectDetailFailure(
              error: NetworkExceptions.internalServerError(),
            ),
          ],
        );
      },
    );

    group(
      'Update Project Member Role',
      () {
        blocTest<ProjectDetailBloc, ProjectDetailState>(
          'Success',
          setUp: () {
            return dioAdapter.onPut(
              updateProjectMemberRoleUrl,
              data: memberData,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => projectDetailBloc,
          act: (ProjectDetailBloc bloc) => bloc.add(
            ProjectDetailEvent.updateProjectMemberRole(
              member: member,
              projectDetail: projectDetail,
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <ProjectDetailState>[
            ProjectDetailState.fetchProjectDetailSuccess(
              projectDetail: projectDetail,
            ),
          ],
        );

        blocTest<ProjectDetailBloc, ProjectDetailState>(
          'Failure',
          setUp: () {
            return dioAdapter.onPut(
              updateProjectMemberRoleUrl,
              data: memberData,
              (MockServer request) => request.reply(500, null),
            );
          },
          build: () => projectDetailBloc,
          act: (ProjectDetailBloc bloc) => bloc.add(
            ProjectDetailEvent.updateProjectMemberRole(
              member: member,
              projectDetail: projectDetail,
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <ProjectDetailState>[
            const ProjectDetailState.updateProjectMemberRoleFailure(
              error: NetworkExceptions.internalServerError(),
            ),
          ],
        );
      },
    );

    group(
      'Remove Member',
      () {
        blocTest<ProjectDetailBloc, ProjectDetailState>(
          'Success',
          setUp: () {
            return dioAdapter.onPut(
              removeMemberUrl,
              data: memberData,
              (MockServer request) => request.reply(204, null),
            );
          },
          build: () => projectDetailBloc,
          act: (ProjectDetailBloc bloc) => bloc.add(
            const ProjectDetailEvent.removeMember(
              projectId: projectId,
              userId: userId,
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <ProjectDetailState>[
            const ProjectDetailState.loadInProgress(),
            const ProjectDetailState.removeMemberSuccess(),
          ],
        );

        blocTest<ProjectDetailBloc, ProjectDetailState>(
          'Failure',
          setUp: () {
            return dioAdapter.onPut(
              removeMemberUrl,
              data: memberData,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => projectDetailBloc,
          act: (ProjectDetailBloc bloc) => bloc.add(
            const ProjectDetailEvent.removeMember(
              projectId: projectId,
              userId: userId,
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <ProjectDetailState>[
            const ProjectDetailState.loadInProgress(),
            const ProjectDetailState.removeMemberFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );

    group(
      'Delete Project',
      () {
        blocTest<ProjectDetailBloc, ProjectDetailState>(
          'Success',
          setUp: () {
            return dioAdapter.onPut(
              deleteProjectUrl,
              data: memberData,
              (MockServer request) => request.reply(204, null),
            );
          },
          build: () => projectDetailBloc,
          act: (ProjectDetailBloc bloc) => bloc.add(
            const ProjectDetailEvent.deleteProject(
              projectId: projectId,
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <ProjectDetailState>[
            const ProjectDetailState.loadInProgress(),
            const ProjectDetailState.deleteProjectSuccess(),
          ],
        );

        blocTest<ProjectDetailBloc, ProjectDetailState>(
          'Failure',
          setUp: () {
            return dioAdapter.onPut(
              deleteProjectUrl,
              data: memberData,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => projectDetailBloc,
          act: (ProjectDetailBloc bloc) => bloc.add(
            const ProjectDetailEvent.deleteProject(
              projectId: projectId,
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <ProjectDetailState>[
            const ProjectDetailState.loadInProgress(),
            const ProjectDetailState.deleteProjectFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );
  });
}
