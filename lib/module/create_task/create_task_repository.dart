import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:pma/config/http_client_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/task.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

class CreateTaskRepository {
  CreateTaskRepository({
    required this.httpClient,
  });

  final HttpClientConfig httpClient;

  Future<ApiResult<int?>> createTask({
    required Map<String, dynamic> taskData,
  }) async {
    try {
      final http.Response response = await http.post(
        Uri.parse('${httpClient.baseUrl}$tasksEndpoint/create'),
        headers: <String, String>{
          HttpHeaders.authorizationHeader: httpClient.token,
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(taskData),
      );
      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse =
            jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResult<int?>.success(
          data: Task.fromJson(jsonResponse).id,
        );
      } else {
        return const ApiResult<int?>.success(
          data: null,
        );
      }

      // final Map<String, dynamic>? data =
      //     await dioClient.request<Map<String, dynamic>?>(
      //   url: 'tasksEndpoint/create',
      //   httpMethod: HttpMethod.post,
      //   data: FormData.fromMap(taskData),
      // );
      // return ApiResult<int?>.success(
      //   data: data != null ? Task.fromJson(data).id : null,
      // );
    } on Exception catch (e) {
      return ApiResult<int?>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }
}
