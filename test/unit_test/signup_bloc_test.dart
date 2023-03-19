import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:http_mock_adapter/src/handlers/request_handler.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/create_user.dart';
import 'package:pma/module/app/user_repository.dart';
import 'package:pma/module/signup/signup/signup_bloc.dart';
import 'package:pma/utils/network_exceptions.dart';

void main() {
  group('Update Password Bloc', () {
    late Dio dio;
    late DioAdapter dioAdapter;
    late SignupBloc signupBloc;
    const String signupUrl = signupEndpoint;
    final CreateUser createUser = CreateUser(
      firstName: 'firstName',
      lastName: 'lastName',
      username: 'username',
      email: 'email',
      password: '',
    );
    final Map<String, dynamic> createUserData = createUser.toJson();

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
      signupBloc = SignupBloc(
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
      'Update Password',
      () {
        blocTest<SignupBloc, SignupState>(
          'Success',
          setUp: () {
            return dioAdapter.onPost(
              signupUrl,
              data: createUserData,
              (MockServer request) => request.reply(201, null),
            );
          },
          build: () => signupBloc,
          act: (SignupBloc bloc) => bloc.add(
            SignupEvent.signupSubmitted(
              user: createUser,
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <SignupState>[
            const SignupState.loadInProgress(),
            SignupState.signupSuccess(user: createUser),
          ],
        );

        blocTest<SignupBloc, SignupState>(
          'Failure',
          setUp: () {
            return dioAdapter.onPost(
              signupUrl,
              data: createUserData,
              (MockServer request) => request.reply(500, null),
            );
          },
          build: () => signupBloc,
          act: (SignupBloc bloc) => bloc.add(
            SignupEvent.signupSubmitted(
              user: createUser,
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <SignupState>[
            const SignupState.loadInProgress(),
            const SignupState.signupFailure(
              error: NetworkExceptions.internalServerError(),
            ),
          ],
        );
      },
    );
  });
}
