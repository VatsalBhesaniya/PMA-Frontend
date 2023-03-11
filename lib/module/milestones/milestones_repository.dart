import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:pma/config/http_client_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/milestone.dart';
import 'package:pma/models/roadmap.dart';
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

  Future<ApiResult<Milestone>> fetchMilestone({
    required int milestoneId,
  }) async {
    try {
      final Map<String, dynamic>? data =
          await dioClient.request<Map<String, dynamic>?>(
        url: '$milestonesEndpoint/$milestoneId',
        httpMethod: HttpMethod.get,
      );
      if (data == null) {
        return const ApiResult<Milestone>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }
      return ApiResult<Milestone>.success(
        data: Milestone.fromJson(data),
      );
    } on Exception catch (e) {
      return ApiResult<Milestone>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }

  Future<ApiResult<Roadmap>> fetchMilestones({
    required int projectId,
  }) async {
    try {
      final Map<String, dynamic>? data =
          await dioClient.request<Map<String, dynamic>?>(
        url: '$projectMilestonesEndpoint/$projectId',
        httpMethod: HttpMethod.get,
      );
      if (data == null) {
        return const ApiResult<Roadmap>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }
      return ApiResult<Roadmap>.success(
        data: Roadmap.fromJson(data),
      );
    } on Exception catch (e) {
      return ApiResult<Roadmap>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }

  Future<ApiResult<Milestone>> updateMilestone({
    required int milestoneId,
    required Map<String, dynamic> milestoneData,
  }) async {
    try {
      final http.Response response = await http.put(
        Uri.parse('${httpClient.baseUrl}$milestonesEndpoint/$milestoneId'),
        headers: <String, String>{
          HttpHeaders.authorizationHeader: httpClient.token,
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(milestoneData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse =
            jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResult<Milestone>.success(
          data: Milestone.fromJson(jsonResponse),
        );
      } else {
        return const ApiResult<Milestone>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }
    } on Exception catch (e) {
      return ApiResult<Milestone>.failure(
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

  Future<ApiResult<void>> deleteMilestone({
    required int milestoneId,
  }) async {
    try {
      await dioClient.request<void>(
        url: '$milestonesEndpoint/$milestoneId',
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
