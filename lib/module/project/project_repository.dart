import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/project.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';

class ProjectRepository {
  ProjectRepository({
    required this.dioClient,
  });
  final DioClient dioClient;

  Future<ApiResult<Project?>> fetchProject({
    required int projectId,
  }) async {
    try {
      final Map<String, dynamic>? data =
          await dioClient.request<Map<String, dynamic>?>(
        url: '$projectsEndpoint/$projectId',
        httpMethod: HttpMethod.get,
      );
      return ApiResult<Project?>.success(
        data: Project.fromJson(data!),
      );
    } on Exception catch (e) {
      return ApiResult<Project?>.failure(
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
