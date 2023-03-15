import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/project_detail.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';

class ProjectDetailRepository {
  ProjectDetailRepository({
    required this.dioConfig,
    required this.dio,
  });
  final DioConfig dioConfig;
  final Dio dio;

  Future<ApiResult<ProjectDetail?>> fetchProjectDetail({
    required int projectId,
  }) async {
    try {
      final Response<Map<String, dynamic>?> response =
          await dio.get<Map<String, dynamic>?>(
        '$projectDetailEndpoint/$projectId',
        options: Options(
          headers: dioConfig.headers,
        ),
      );
      final Map<String, dynamic>? data = response.data;
      if (data == null) {
        return const ApiResult<ProjectDetail?>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }
      return ApiResult<ProjectDetail?>.success(
        data: ProjectDetail.fromJson(data),
      );
    } on Exception catch (e) {
      return ApiResult<ProjectDetail?>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }

  Future<ApiResult<void>> updateProjectDetail({
    required int projectId,
    required Map<String, dynamic> projectData,
  }) async {
    try {
      await dio.put<Map<String, dynamic>?>(
        '$projectsEndpoint/$projectId',
        options: Options(
          headers: dioConfig.headers,
        ),
        data: projectData,
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

  Future<ApiResult<void>> updateProjectMemberRole({
    required Map<String, dynamic> memberData,
  }) async {
    try {
      await dio.put<Map<String, dynamic>?>(
        inviteMembersEndpoint,
        options: Options(
          headers: dioConfig.headers,
        ),
        data: memberData,
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

  Future<ApiResult<void>> removeMember({
    required int projectId,
    required int userId,
  }) async {
    try {
      await dio.delete<void>(
        '$membersEndpoint/$projectId/$userId',
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

  Future<ApiResult<void>> deleteProject({
    required int projectId,
  }) async {
    try {
      await dio.delete<void>(
        '$projectsEndpoint/$projectId',
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
