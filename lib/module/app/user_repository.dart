import 'package:dio/dio.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/manager/app_storage_manager.dart';
import 'package:pma/models/search_user.dart';
import 'package:pma/models/user.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

class UserRepository {
  UserRepository({
    required this.dioConfig,
    required this.dio,
    required this.appStorageManager,
  });
  final DioConfig dioConfig;
  final Dio dio;
  final AppStorageManager appStorageManager;

  // getToken
  Future<String?> getToken() async {
    final String? token = await appStorageManager.getUserToken();
    return token;
  }

  // getToken string
  Future<String?> getTokenString() async {
    final String? tokenString = await appStorageManager.getUserTokenString();
    return tokenString;
  }

  // persistToken
  Future<void> persistToken(String token) async {
    appStorageManager.setUserToken('Bearer $token');
    appStorageManager.setUserTokenString(token);
  }

  // deleteToken
  Future<void> deleteToken() async {
    appStorageManager.clearStorage();
  }

  Future<ApiResult<String>> login({
    required String email,
    required String password,
  }) async {
    try {
      final Response<Map<String, dynamic>?> response =
          await dio.post<Map<String, dynamic>?>(
        loginEndpoint,
        options: Options(
          headers: dioConfig.headers,
        ),
        data: FormData.fromMap(<String, dynamic>{
          'username': email,
          'password': password,
        }),
      );
      final Map<String, dynamic>? data = response.data;
      if (data == null) {
        return const ApiResult<String>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }
      return ApiResult<String>.success(
        data: data['access_token'] as String,
      );
    } on Exception catch (e) {
      return ApiResult<String>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }

  Future<ApiResult<void>> signup({
    required Map<String, dynamic> userJson,
  }) async {
    try {
      final Response<Map<String, dynamic>?> response =
          await dio.post<Map<String, dynamic>?>(
        signupEndpoint,
        options: Options(
          headers: dioConfig.headers,
        ),
        data: userJson,
      );
      final Map<String, dynamic>? data = response.data;
      if (data == null) {
        return const ApiResult<String?>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }
      if (response.statusCode == 201) {
        return const ApiResult<void>.success(
          data: null,
        );
      } else {
        return const ApiResult<void>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }
    } on Exception catch (e) {
      return ApiResult<void>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }

  // getUser
  Future<ApiResult<User>> fetchCurrentUser({
    required String token,
  }) async {
    try {
      final Response<Map<String, dynamic>?> response =
          await dio.get<Map<String, dynamic>?>(
        '$currentUsersEndpoint/$token',
        options: Options(
          headers: dioConfig.headers,
        ),
      );
      final Map<String, dynamic>? data = response.data;
      if (data == null) {
        return const ApiResult<User>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }
      return ApiResult<User>.success(
        data: User.fromJson(data),
      );
    } on Exception catch (e) {
      return ApiResult<User>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }

  Future<ApiResult<List<SearchUser>>> fetchUsers({
    required int projectId,
    required String searchText,
  }) async {
    try {
      final Response<List<dynamic>?> response = await dio.get<List<dynamic>?>(
        '$usersEndpoint/$projectId?search=$searchText',
        options: Options(
          headers: dioConfig.headers,
        ),
      );
      final List<dynamic>? data = response.data;
      if (data == null) {
        return const ApiResult<List<SearchUser>>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }
      final List<SearchUser> users = data
          .map((dynamic user) =>
              SearchUser.fromJson(user as Map<String, dynamic>))
          .toList();
      return ApiResult<List<SearchUser>>.success(
        data: users,
      );
    } on Exception catch (e) {
      return ApiResult<List<SearchUser>>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }

  Future<ApiResult<void>> updateUserPassword({
    required Map<String, dynamic> userData,
  }) async {
    try {
      final Response<Map<String, dynamic>?> response =
          await dio.put<Map<String, dynamic>?>(
        updatePasswordEndpoint,
        options: Options(
          headers: dioConfig.headers,
        ),
        data: userData,
      );
      if (response.statusCode == 200) {
        return const ApiResult<void>.success(
          data: null,
        );
      }
      return const ApiResult<void>.failure(
        error: NetworkExceptions.defaultError(),
      );
    } on Exception catch (e) {
      return ApiResult<void>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }
}
