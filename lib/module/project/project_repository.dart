import 'package:dio/dio.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/project.dart';
import 'package:pma/models/search_user.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

class ProjectRepository {
  ProjectRepository({
    required this.dioConfig,
    required this.dio,
  });
  final DioConfig dioConfig;
  final Dio dio;

  Future<ApiResult<Project>> fetchProject({
    required int projectId,
  }) async {
    try {
      final Response<Map<String, dynamic>?> response =
          await dio.get<Map<String, dynamic>?>(
        '$projectsEndpoint/$projectId',
        options: Options(
          headers: dioConfig.headers,
        ),
      );
      final Map<String, dynamic>? data = response.data;
      if (data == null) {
        return const ApiResult<Project>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }
      return ApiResult<Project>.success(
        data: Project.fromJson(data),
      );
    } on Exception catch (e) {
      return ApiResult<Project>.failure(
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
      final Response<List<dynamic>?> response = await dio.get<List<dynamic>?>(
        '$projectMembersEndpoint/$projectId/$taskId?search=$searchText',
        options: Options(
          headers: dioConfig.headers,
        ),
      );
      final List<dynamic>? data = response.data;
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
