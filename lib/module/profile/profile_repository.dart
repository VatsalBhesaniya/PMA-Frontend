import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/user.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';

class ProfileRepository {
  ProfileRepository({
    required this.dioClient,
  });

  final DioClient dioClient;

  Future<ApiResult<User>> updateUser({
    required int userId,
    required Map<String, dynamic> userData,
  }) async {
    try {
      final Map<String, dynamic>? data =
          await dioClient.request<Map<String, dynamic>?>(
        url: '$usersEndpoint/$userId',
        httpMethod: HttpMethod.put,
        data: userData,
      );
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
      await dioClient.request<void>(
        url: '$usersEndpoint/$userId',
        httpMethod: HttpMethod.delete,
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
