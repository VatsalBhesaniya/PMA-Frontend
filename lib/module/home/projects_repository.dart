import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:pma/config/http_client_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/project.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';

class ProjectsRepository {
  ProjectsRepository({
    required this.dioClient,
    required this.httpClient,
  });
  final DioClient dioClient;
  final HttpClientConfig httpClient;

  Future<ApiResult<List<Project>?>> fetchProjects() async {
    try {
      final List<dynamic>? data = await dioClient.request<List<dynamic>?>(
        url: projectsEndpoint,
        httpMethod: HttpMethod.get,
      );
      final List<Project>? projects = data
          ?.map((dynamic project) =>
              Project.fromJson(project as Map<String, dynamic>))
          .toList();
      return ApiResult<List<Project>?>.success(
        data: projects,
      );
    } on Exception catch (e) {
      return ApiResult<List<Project>?>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }

  Future<ApiResult<bool>> createProject({
    required Map<String, dynamic> projectJson,
  }) async {
    try {
      final String? token =
          await const FlutterSecureStorage().read(key: 'token');
      final http.Response response = await http.post(
        Uri.parse('${httpClient.baseUrl}$createProjectEndpoint'),
        headers: <String, String>{
          HttpHeaders.authorizationHeader: token!,
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(projectJson),
      );
      if (response.statusCode == 201) {
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
