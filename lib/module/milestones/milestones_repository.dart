import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:pma/config/http_client_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/milestone.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';

class MilestonesRepository {
  MilestonesRepository({
    required this.dioClient,
    required this.httpClient,
  });

  final DioClient dioClient;
  final HttpClientConfig httpClient;

  Future<ApiResult<List<Milestone>>> fetchMilestones({
    required int projectId,
  }) async {
    try {
      final List<dynamic>? data = await dioClient.request<List<dynamic>?>(
        url: '$projectMilestonesEndpoint/$projectId',
        httpMethod: HttpMethod.get,
      );
      if (data == null) {
        return const ApiResult<List<Milestone>>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }
      final List<Milestone> milestones = data
          .map((dynamic project) =>
              Milestone.fromJson(project as Map<String, dynamic>))
          .toList();
      milestones.sort(
        (Milestone a, Milestone b) =>
            a.completionDate.compareTo(b.completionDate),
      );
      return ApiResult<List<Milestone>>.success(
        data: milestones,
      );
    } on Exception catch (e) {
      return ApiResult<List<Milestone>>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }

  Future<ApiResult<void>> createMilestone({
    required Map<String, dynamic> milestonesData,
  }) async {
    try {
      final http.Response response = await http.post(
        Uri.parse('${httpClient.baseUrl}$createMilestonesEndpoint'),
        headers: <String, String>{
          HttpHeaders.authorizationHeader: httpClient.token,
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(milestonesData),
      );
      if (response.statusCode == 200) {
        return const ApiResult<void>.success(
          data: null,
        );
      } else {
        return const ApiResult<void>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }
    } on Exception catch (e) {
      return ApiResult<void>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }
}
