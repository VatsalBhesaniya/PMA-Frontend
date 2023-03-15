import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/dio_client.dart';
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
      await dio.post<void>(
        inviteMembersEndpoint,
        options: Options(
          headers: dioConfig.headers,
        ),
        data: membersData,
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
