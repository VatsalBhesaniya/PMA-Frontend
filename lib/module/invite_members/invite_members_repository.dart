import 'package:pma/constants/api_constants.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';

class InviteMembersRepository {
  InviteMembersRepository({
    required this.dioClient,
  });

  final DioClient dioClient;

  Future<ApiResult<void>> inviteMembers({
    required List<Map<String, dynamic>> membersData,
  }) async {
    try {
      await dioClient.request<void>(
        url: inviteMembersEndpoint,
        httpMethod: HttpMethod.post,
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
