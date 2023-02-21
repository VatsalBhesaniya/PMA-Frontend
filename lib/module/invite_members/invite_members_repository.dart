import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:pma/config/http_client_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';

class InviteMembersRepository {
  InviteMembersRepository({
    required this.dioClient,
    required this.httpClient,
  });

  final DioClient dioClient;
  final HttpClientConfig httpClient;

  Future<ApiResult<bool>> inviteMembers({
    required List<Map<String, dynamic>> membersData,
  }) async {
    try {
      final String? token =
          await const FlutterSecureStorage().read(key: 'token');
      final http.Response response = await http.post(
        Uri.parse('${httpClient.baseUrl}$inviteMembersEndpoint'),
        headers: <String, String>{
          HttpHeaders.authorizationHeader: token!,
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(membersData),
      );
      if (response.statusCode == 200) {
        return const ApiResult<bool>.success(
          data: true,
        );
      } else {
        return const ApiResult<bool>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }
    } on Exception catch (e) {
      return ApiResult<bool>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }
}
