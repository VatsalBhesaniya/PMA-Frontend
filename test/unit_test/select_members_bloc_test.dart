import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:http_mock_adapter/src/handlers/request_handler.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/search_user.dart';
import 'package:pma/module/project/project_repository.dart';
import 'package:pma/module/select_members/bloc/select_members_bloc.dart';
import 'package:pma/utils/network_exceptions.dart';

void main() {
  group('Select Members Bloc', () {
    late Dio dio;
    late DioAdapter dioAdapter;
    late SelectMembersBloc selectMembersBloc;
    const int projectId = 1;
    const int taskId = 1;
    const int userId = 1;
    const String searchText = '';
    const String fetchProjectMembersUrl =
        '$projectMembersEndpoint/$projectId/$taskId?search=$searchText';
    final SearchUser searchUser = SearchUser(
      id: userId,
      username: 'username',
      email: 'email',
    );
    final List<dynamic> searchUsersData = <dynamic>[searchUser.toJson()];

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
      selectMembersBloc = SelectMembersBloc(
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
      'Search Members',
      () {
        blocTest<SelectMembersBloc, SelectMembersState>(
          'Success',
          setUp: () {
            return dioAdapter.onGet(
              fetchProjectMembersUrl,
              (MockServer request) => request.reply(200, searchUsersData),
            );
          },
          build: () => selectMembersBloc,
          act: (SelectMembersBloc bloc) => bloc.add(
            const SelectMembersEvent.searchUsers(
              projectId: projectId,
              searchText: '',
              taskId: taskId,
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <SelectMembersState>[
            const SelectMembersState.loadInProgress(),
            SelectMembersState.searchUsersSuccess(
              users: <SearchUser>[searchUser],
            ),
          ],
        );

        blocTest<SelectMembersBloc, SelectMembersState>(
          'Failure',
          setUp: () {
            return dioAdapter.onGet(
              fetchProjectMembersUrl,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => selectMembersBloc,
          act: (SelectMembersBloc bloc) => bloc.add(
            const SelectMembersEvent.searchUsers(
              projectId: projectId,
              searchText: '',
              taskId: taskId,
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <SelectMembersState>[
            const SelectMembersState.loadInProgress(),
            const SelectMembersState.searchUsersFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );
  });
}
