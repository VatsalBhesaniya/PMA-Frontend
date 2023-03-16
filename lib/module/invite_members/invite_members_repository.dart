import 'package:dio/dio.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

class InviteMembersRepository {
  InviteMembersRepository({
    required this.dioConfig,
    required this.dio,
  });
  final DioConfig dioConfig;
  final Dio dio;

  Future<ApiResult<void>> inviteMembers({
    required List<Map<String, dynamic>> membersData,
  }) async {
    try {
      final Response<void> response = await dio.post<void>(
        inviteMembersEndpoint,
        options: Options(
          headers: dioConfig.headers,
        ),
        data: membersData,
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
