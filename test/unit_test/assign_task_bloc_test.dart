import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:http_mock_adapter/src/handlers/request_handler.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/constants/enum.dart';
import 'package:pma/models/invite_member.dart';
import 'package:pma/models/search_user.dart';
import 'package:pma/module/assign_task/bloc/assign_task_bloc.dart';
import 'package:pma/module/task/task_repository.dart';
import 'package:pma/utils/network_exceptions.dart';

void main() {
  group('Assign Task Bloc', () {
    late Dio dio;
    late DioAdapter dioAdapter;
    late AssignTaskBloc assignTaskBloc;
    const int taskId = 1;
    const int projectId = 1;
    const int userId = 1;
    const String assignTaskUrl = '$assignTasksEndpoint/$taskId';
    final InviteMember inviteMember = InviteMember(
      userId: userId,
      projectId: projectId,
      role: MemberRole.member.index + 1,
    );
    final List<Map<String, dynamic>> inviteMemberData = <Map<String, dynamic>>[
      inviteMember.toJson()
    ];
    final SearchUser searchUser = SearchUser(
      id: userId,
      username: 'username',
      email: 'email',
    );

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
      assignTaskBloc = AssignTaskBloc(
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
      'Assign Member',
      () {
        blocTest<AssignTaskBloc, AssignTaskState>(
          'Success',
          setUp: () {
            return dioAdapter.onPost(
              assignTaskUrl,
              data: inviteMemberData,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => assignTaskBloc,
          act: (AssignTaskBloc bloc) => bloc.add(
            AssignTaskEvent.assignTaskToMember(
              projectId: projectId,
              taskId: taskId,
              users: <SearchUser>[searchUser],
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <AssignTaskState>[
            const AssignTaskState.loadInProgress(),
            const AssignTaskState.assignTaskToMemberSuccess(),
          ],
        );

        blocTest<AssignTaskBloc, AssignTaskState>(
          'Failure',
          setUp: () {
            return dioAdapter.onPost(
              assignTaskUrl,
              data: inviteMemberData,
              (MockServer request) => request.reply(500, null),
            );
          },
          build: () => assignTaskBloc,
          act: (AssignTaskBloc bloc) => bloc.add(
            AssignTaskEvent.assignTaskToMember(
              projectId: projectId,
              taskId: taskId,
              users: <SearchUser>[searchUser],
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <AssignTaskState>[
            const AssignTaskState.loadInProgress(),
            const AssignTaskState.assignTaskToMemberFailure(
              error: NetworkExceptions.internalServerError(),
            ),
          ],
        );
      },
    );
  });
}
