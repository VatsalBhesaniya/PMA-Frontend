import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:http_mock_adapter/src/handlers/request_handler.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/update_user.dart';
import 'package:pma/models/user.dart';
import 'package:pma/module/app/user_repository.dart';
import 'package:pma/module/profile/bloc/profile_bloc.dart';
import 'package:pma/module/profile/profile_repository.dart';
import 'package:pma/utils/network_exceptions.dart';

void main() {
  group('Profile Bloc', () {
    late Dio dio;
    late DioAdapter dioAdapter;
    late ProfileBloc profileBloc;
    const String token = 'token';
    const int userId = 1;
    const String fetchUserUrl = '$currentUsersEndpoint/$token';
    const String updateUserUrl = '$usersEndpoint/$userId';
    const String deleteUserUrl = '$usersEndpoint/$userId';
    final User user = User(
      id: userId,
      firstName: 'firstName',
      lastName: 'lastName',
      username: 'username',
      email: 'email',
      createdAt: '2023-03-16T02:51:10.577757+05:30',
    );
    final Map<String, dynamic> userData = user.toJson();
    final UpdateUser updateUser = UpdateUser(
      firstName: 'firstName',
      lastName: 'lastName',
      username: 'username',
      email: 'email',
    );
    final Map<String, dynamic> updateUserData = updateUser.toJson();

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
      final DioConfig dioConfig = DioConfig(
        baseUrl: iosBaseUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'authorization': 'token'
        },
      );
      profileBloc = ProfileBloc(
        profileRepository: ProfileRepository(
          dio: dio,
          dioConfig: dioConfig,
        ),
        userRepository: UserRepository(
          dio: dio,
          dioConfig: dioConfig,
        ),
      );
    });

    group(
      'Fetch Profile',
      () {
        blocTest<ProfileBloc, ProfileState>(
          'Success',
          setUp: () {
            return dioAdapter.onGet(
              fetchUserUrl,
              (MockServer request) => request.reply(200, userData),
            );
          },
          build: () => profileBloc,
          act: (ProfileBloc bloc) => bloc.add(
            const ProfileEvent.fetchUser(
              token: token,
              userId: userId,
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <ProfileState>[
            ProfileState.fetchUserSucceess(user: user),
          ],
        );

        blocTest<ProfileBloc, ProfileState>(
          'Failure',
          setUp: () {
            return dioAdapter.onGet(
              fetchUserUrl,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => profileBloc,
          act: (ProfileBloc bloc) => bloc.add(
            const ProfileEvent.fetchUser(
              token: token,
              userId: userId,
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <ProfileState>[
            const ProfileState.fetchUserFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );

    group(
      'Update Profile',
      () {
        blocTest<ProfileBloc, ProfileState>(
          'Success',
          setUp: () {
            return dioAdapter.onPut(
              updateUserUrl,
              data: updateUserData,
              (MockServer request) => request.reply(200, userData),
            );
          },
          build: () => profileBloc,
          act: (ProfileBloc bloc) => bloc.add(
            ProfileEvent.updateProfile(
              userId: userId,
              user: updateUser,
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <ProfileState>[
            const ProfileState.updateUserSuccess(),
          ],
        );

        blocTest<ProfileBloc, ProfileState>(
          'Failure',
          setUp: () {
            return dioAdapter.onPut(
              updateUserUrl,
              data: updateUserData,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => profileBloc,
          act: (ProfileBloc bloc) => bloc.add(
            ProfileEvent.updateProfile(
              userId: userId,
              user: updateUser,
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <ProfileState>[
            const ProfileState.updateUserFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );

    group(
      'Delete Profile',
      () {
        blocTest<ProfileBloc, ProfileState>(
          'Success',
          setUp: () {
            return dioAdapter.onDelete(
              deleteUserUrl,
              (MockServer request) => request.reply(204, null),
            );
          },
          build: () => profileBloc,
          act: (ProfileBloc bloc) => bloc.add(
            const ProfileEvent.deleteProfile(userId: userId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <ProfileState>[
            const ProfileState.deleteUserSuccess(),
          ],
        );

        blocTest<ProfileBloc, ProfileState>(
          'Failure',
          setUp: () {
            return dioAdapter.onDelete(
              deleteUserUrl,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => profileBloc,
          act: (ProfileBloc bloc) => bloc.add(
            const ProfileEvent.deleteProfile(userId: userId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <ProfileState>[
            const ProfileState.deleteUserFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );
  });
}
