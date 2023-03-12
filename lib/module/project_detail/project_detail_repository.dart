import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/project_detail.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';

class ProjectDetailRepository {
  ProjectDetailRepository({
    required this.dioClient,
  });
  final DioClient dioClient;

  Future<ApiResult<ProjectDetail?>> fetchProjectDetail({
    required int projectId,
  }) async {
    try {
      final Map<String, dynamic>? data =
          await dioClient.request<Map<String, dynamic>?>(
        url: '$projectDetailEndpoint/$projectId',
        httpMethod: HttpMethod.get,
      );
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
      await dioClient.request<void>(
        url: '$projectsEndpoint/$projectId',
        httpMethod: HttpMethod.put,
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
      await dioClient.request<Map<String, dynamic>?>(
        url: inviteMembersEndpoint,
        httpMethod: HttpMethod.put,
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

  Future<ApiResult<bool>> removeMember({
    required int projectId,
    required int userId,
  }) async {
    try {
      await dioClient.request<void>(
        url: '$membersEndpoint/$projectId/$userId',
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
