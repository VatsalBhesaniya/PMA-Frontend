import 'package:pma/constants/api_constants.dart';
import 'package:pma/manager/app_storage_manager.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';

class UserRepository {
  UserRepository({
    required this.dioClient,
    required this.appStorageManager,
  });
  final DioClient dioClient;
  final AppStorageManager appStorageManager;

  // getUser

  // hasToken
  Future<bool> hasToken() async {
    final String? token = await appStorageManager.getUserToken();
    return token != null;
  }

  // persistToken
  Future<void> persistToken(String token) async {
    appStorageManager.setUserToken(token);
  }

  // deleteToken
  Future<void> deleteToken() async {
    appStorageManager.clearStorage();
  }

  //login
  Future<ApiResult<String?>> login({
    required String email,
    required String password,
  }) async {
    try {
      final Map<String, dynamic>? data = await dioClient.request(
        url: loginEndpoint,
        httpMethod: HttpMethod.post,
        data: FormData.fromMap(<String, dynamic>{
          'username': email,
          'password': password,
        }),
      );
      return ApiResult<String?>.success(
        data: data != null ? data['access_token'] as String : null,
      );
    } on Exception catch (e) {
      return ApiResult<String?>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }
}
