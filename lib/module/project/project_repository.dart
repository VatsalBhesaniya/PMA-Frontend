import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/project.dart';
import 'package:pma/models/search_user.dart';
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

  Future<ApiResult<List<SearchUser>>> fetchProjectMembers({
    required String searchText,
    required int projectId,
    required int taskId,
  }) async {
    try {
      final List<dynamic>? data = await dioClient.request<List<dynamic>?>(
        url: '$projectMembersEndpoint/$projectId/$taskId?search=$searchText',
        httpMethod: HttpMethod.get,
      );
      if (data == null) {
        return const ApiResult<List<SearchUser>>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }
      final List<SearchUser> users = data
          .map((dynamic user) =>
              SearchUser.fromJson(user as Map<String, dynamic>))
          .toList();
      return ApiResult<List<SearchUser>>.success(
        data: users,
      );
    } on Exception catch (e) {
      return ApiResult<List<SearchUser>>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }
}
