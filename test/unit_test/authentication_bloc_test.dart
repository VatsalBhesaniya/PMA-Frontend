import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:http_mock_adapter/src/handlers/request_handler.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/user.dart';
import 'package:pma/module/app/user_repository.dart';
import 'package:pma/module/authentication/bloc/authentication_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  group('Authentication Bloc', () {
    late Dio dio;
    late DioAdapter dioAdapter;
    late AuthenticationBloc noteBloc;
    late UserRepository userRepository;
    const String token = 'token';
    const String fetchCurrentUsersUrl = '$currentUsersEndpoint/$token';
    final User user = User(
      id: 1,
      firstName: 'firstName',
      lastName: 'lastName',
      username: 'username',
      email: 'email',
      createdAt: '2023-03-16T02:51:10.577757+05:30',
    );
    final Map<String, dynamic> userData = user.toJson();

    setUp(() async {
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
      userRepository = UserRepository(
        dio: dio,
        dioConfig: DioConfig(
          baseUrl: iosBaseUrl,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'authorization': 'token'
          },
        ),
      );
      noteBloc = AuthenticationBloc(
        userRepository: userRepository,
      );
    });

    group(
      'App Started',
      () {
        blocTest<AuthenticationBloc, AuthenticationState>(
          'Success',
          setUp: () {
            return dioAdapter.onGet(
              fetchCurrentUsersUrl,
              (MockServer request) => request.reply(200, userData),
            );
          },
          build: () => noteBloc,
          act: (AuthenticationBloc bloc) => bloc.add(
            const AuthenticationEvent.appStarted(
              token: token,
              tokenString: token,
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <AuthenticationState>[
            const AuthenticationState.loadInProgress(),
            AuthenticationState.authenticated(
              token: token,
              user: user,
            ),
          ],
        );

        blocTest<AuthenticationBloc, AuthenticationState>(
          'Failure',
          setUp: () {
            return dioAdapter.onGet(
              fetchCurrentUsersUrl,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => noteBloc,
          act: (AuthenticationBloc bloc) => bloc.add(
            const AuthenticationEvent.appStarted(
              token: token,
              tokenString: token,
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <AuthenticationState>[
            const AuthenticationState.loadInProgress(),
            const AuthenticationState.unauthenticated(),
          ],
        );
      },
    );

    group(
      'Logout',
      () {
        blocTest<AuthenticationBloc, AuthenticationState>(
          'Success',
          setUp: () {},
          build: () => noteBloc,
          act: (AuthenticationBloc bloc) => bloc.add(
            const AuthenticationEvent.logout(),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <AuthenticationState>[
            const AuthenticationState.unauthenticated(),
          ],
        );
      },
    );
  });
}
