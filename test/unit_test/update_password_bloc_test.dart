import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:http_mock_adapter/src/handlers/request_handler.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/update_password.dart';
import 'package:pma/models/user.dart';
import 'package:pma/module/app/user_repository.dart';
import 'package:pma/module/update_password/bloc/update_password_bloc.dart';
import 'package:pma/utils/network_exceptions.dart';

void main() {
  group('Update Password Bloc', () {
    late Dio dio;
    late DioAdapter dioAdapter;
    late UpdatePasswordBloc updatePasswordBloc;
    const int userId = 1;
    const String updatePasswordUrl = updatePasswordEndpoint;
    final User user = User(
      id: userId,
      firstName: 'firstName',
      lastName: 'lastName',
      username: 'username',
      email: 'email',
      createdAt: '2023-03-16T02:51:10.577757+05:30',
    );
    final Map<String, dynamic> userData = user.toJson();
    final UpdatePassword updatePassword = UpdatePassword(
      email: 'email',
      password: 'password',
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
      updatePasswordBloc = UpdatePasswordBloc(
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
        blocTest<UpdatePasswordBloc, UpdatePasswordState>(
          'Success',
          setUp: () {
            return dioAdapter.onPut(
              updatePasswordUrl,
              (MockServer request) => request.reply(200, userData),
            );
          },
          build: () => updatePasswordBloc,
          act: (UpdatePasswordBloc bloc) => bloc.add(
            UpdatePasswordEvent.updatePassword(
              updatePassword: updatePassword,
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <UpdatePasswordState>[
            const UpdatePasswordState.loadInProgress(),
            const UpdatePasswordState.updatePasswordSuccess(),
          ],
        );

        blocTest<UpdatePasswordBloc, UpdatePasswordState>(
          'Failure',
          setUp: () {
            return dioAdapter.onPut(
              updatePasswordUrl,
              (MockServer request) => request.reply(500, null),
            );
          },
          build: () => updatePasswordBloc,
          act: (UpdatePasswordBloc bloc) => bloc.add(
            UpdatePasswordEvent.updatePassword(
              updatePassword: updatePassword,
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <UpdatePasswordState>[
            const UpdatePasswordState.loadInProgress(),
            const UpdatePasswordState.updatePasswordFailure(
              error: NetworkExceptions.internalServerError(),
            ),
          ],
        );
      },
    );
  });
}
