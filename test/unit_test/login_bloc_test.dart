import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:http_mock_adapter/src/handlers/request_handler.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/module/app/user_repository.dart';
import 'package:pma/module/login/bloc/login_bloc.dart';
import 'package:pma/utils/network_exceptions.dart';

void main() {
  group('Login Bloc', () {
    late Dio dio;
    late DioAdapter dioAdapter;
    late LoginBloc loginBloc;
    const String email = 'email';
    const String password = 'password';
    const String token = 'token';
    const String loginUrl = loginEndpoint;
    final FormData loginData = FormData.fromMap(<String, dynamic>{
      'username': email,
      'password': password,
    });
    final Map<String, dynamic> loginResult = <String, dynamic>{
      'access_token': 'token',
      'token_type': 'bearer',
    };

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
      loginBloc = LoginBloc(
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
      'Login',
      () {
        blocTest<LoginBloc, LoginState>(
          'Success',
          setUp: () {
            return dioAdapter.onPost(
              loginUrl,
              data: loginData,
              (MockServer request) => request.reply(200, loginResult),
            );
          },
          build: () => loginBloc,
          act: (LoginBloc bloc) => bloc.add(
            const LoginEvent.loginSubmitted(
              email: email,
              password: password,
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <LoginState>[
            const LoginState.loadInProgress(),
            const LoginState.loginSuccess(token: token),
          ],
        );

        blocTest<LoginBloc, LoginState>(
          'Failure',
          setUp: () {
            return dioAdapter.onPost(
              loginUrl,
              data: loginData,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => loginBloc,
          act: (LoginBloc bloc) => bloc.add(
            const LoginEvent.loginSubmitted(
              email: email,
              password: password,
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <LoginState>[
            const LoginState.loadInProgress(),
            const LoginState.loginFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );
  });
}
