import 'package:dio/dio.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/user.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

class ProfileRepository {
  ProfileRepository({
    required this.dioConfig,
    required this.dio,
  });
  final DioConfig dioConfig;
  final Dio dio;

  Future<ApiResult<User>> updateUser({
    required int userId,
    required Map<String, dynamic> userData,
  }) async {
    try {
      final Response<Map<String, dynamic>?> response =
          await dio.put<Map<String, dynamic>?>(
        '$usersEndpoint/$userId',
        options: Options(
          headers: dioConfig.headers,
        ),
        data: userData,
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

  Future<ApiResult<void>> deleteUser({
    required int userId,
  }) async {
    try {
      await dio.delete<void>(
        '$usersEndpoint/$userId',
        options: Options(
          headers: dioConfig.headers,
        ),
      );
      return const ApiResult<void>.success(
        data: null,
      );
    } on Exception catch (e) {
      return ApiResult<void>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }
}
