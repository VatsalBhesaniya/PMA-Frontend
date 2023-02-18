import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:pma/config/http_client_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/project.dart';
import 'package:pma/models/project_detail.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';

class ProjectDetailRepository {
  ProjectDetailRepository({
    required this.dioClient,
    required this.httpClient,
  });
  final DioClient dioClient;
  final HttpClientConfig httpClient;

  Future<ApiResult<ProjectDetail?>> fetchProjectDetail({
    required int projectId,
  }) async {
    try {
      final Map<String, dynamic>? data =
          await dioClient.request<Map<String, dynamic>?>(
        url: '$projectDetailEndpoint/$projectId',
        httpMethod: HttpMethod.get,
      );
      return ApiResult<ProjectDetail?>.success(
        data: ProjectDetail.fromJson(data!),
      );
    } on Exception catch (e) {
      return ApiResult<ProjectDetail?>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }

  Future<ApiResult<bool>> updateProjectDetail({
    required Project project,
  }) async {
    try {
      final String body = jsonEncode(project.toJson()..remove('id'));
      final String? token =
          await const FlutterSecureStorage().read(key: 'token');
      final http.Response response = await http.put(
        Uri.parse('${httpClient.baseUrl}$projectsEndpoint/${project.id}'),
        headers: <String, String>{
          HttpHeaders.authorizationHeader: token!,
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        return const ApiResult<bool>.success(
          data: true,
        );
      } else {
        return ApiResult<bool>.failure(
          error: NetworkExceptions.dioException(
            Exception('Something went wrong!'),
          ),
        );
      }
    } on Exception catch (e) {
      return ApiResult<bool>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }

  Future<ApiResult<bool>> deleteProject({
    required int projectId,
  }) async {
    try {
      await dioClient.request<void>(
        url: '$projectsEndpoint/$projectId',
        httpMethod: HttpMethod.delete,
      );
      return const ApiResult<bool>.success(
        data: true,
      );
    } on Exception catch (e) {
      return ApiResult<bool>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }
}
