import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/milestone.dart';
import 'package:pma/models/roadmap.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';

class MilestonesRepository {
  MilestonesRepository({
    required this.dioConfig,
    required this.dio,
  });
  final DioConfig dioConfig;
  final Dio dio;

  Future<ApiResult<Milestone>> fetchMilestone({
    required int milestoneId,
  }) async {
    try {
      final Response<Map<String, dynamic>?> response =
          await dio.get<Map<String, dynamic>?>(
        '$milestonesEndpoint/$milestoneId',
        options: Options(
          headers: dioConfig.headers,
        ),
      );
      final Map<String, dynamic>? data = response.data;
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
      final Response<Map<String, dynamic>?> response =
          await dio.get<Map<String, dynamic>?>(
        '$projectMilestonesEndpoint/$projectId',
        options: Options(
          headers: dioConfig.headers,
        ),
      );
      final Map<String, dynamic>? data = response.data;
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
      final Response<Map<String, dynamic>?> response =
          await dio.put<Map<String, dynamic>?>(
        '$milestonesEndpoint/$milestoneId',
        options: Options(
          headers: dioConfig.headers,
        ),
        data: milestoneData,
      );
      final Map<String, dynamic>? data = response.data;
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

  Future<ApiResult<void>> createMilestone({
    required Map<String, dynamic> milestoneData,
  }) async {
    try {
      final Response<Map<String, dynamic>?> response =
          await dio.post<Map<String, dynamic>?>(
        createMilestonesEndpoint,
        options: Options(
          headers: dioConfig.headers,
        ),
        data: milestoneData,
      );
      final Map<String, dynamic>? data = response.data;
      if (data == null) {
        return const ApiResult<void>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }
      return const ApiResult<void>.success(
        data: null,
      );
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
      await dio.delete<Map<String, dynamic>?>(
        '$milestonesEndpoint/$milestoneId',
        options: Options(
          headers: dioConfig.headers,
        ),
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
