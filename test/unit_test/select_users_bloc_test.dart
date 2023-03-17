import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:http_mock_adapter/src/handlers/request_handler.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/search_user.dart';
import 'package:pma/module/app/user_repository.dart';
import 'package:pma/module/select_users/bloc/select_users_bloc.dart';
import 'package:pma/utils/network_exceptions.dart';

void main() {
  group('Select Users Bloc', () {
    late Dio dio;
    late DioAdapter dioAdapter;
    late SelectUsersBloc selectUsersBloc;
    const int projectId = 1;
    const int userId = 1;
    const String searchText = '';
    const String fetchUsersUrl = '$usersEndpoint/$projectId?search=$searchText';
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
      selectUsersBloc = SelectUsersBloc(
        userRepository: UserRepository(
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
      'Search Users',
      () {
        blocTest<SelectUsersBloc, SelectUsersState>(
          'Success',
          setUp: () {
            return dioAdapter.onGet(
              fetchUsersUrl,
              (MockServer request) => request.reply(200, searchUsersData),
            );
          },
          build: () => selectUsersBloc,
          act: (SelectUsersBloc bloc) => bloc.add(
            const SelectUsersEvent.searchUsers(
              projectId: projectId,
              searchText: '',
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <SelectUsersState>[
            const SelectUsersState.loadInProgress(),
            SelectUsersState.searchUsersSuccess(
              users: <SearchUser>[searchUser],
            ),
          ],
        );

        blocTest<SelectUsersBloc, SelectUsersState>(
          'Failure',
          setUp: () {
            return dioAdapter.onGet(
              fetchUsersUrl,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => selectUsersBloc,
          act: (SelectUsersBloc bloc) => bloc.add(
            const SelectUsersEvent.searchUsers(
              projectId: projectId,
              searchText: '',
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <SelectUsersState>[
            const SelectUsersState.loadInProgress(),
            const SelectUsersState.searchUsersFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );
  });
}
