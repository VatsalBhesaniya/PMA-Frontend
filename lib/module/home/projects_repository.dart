import 'package:dio/dio.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/project.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

class ProjectsRepository {
  ProjectsRepository({
    required this.dioConfig,
    required this.dio,
  });
  final DioConfig dioConfig;
  final Dio dio;

  Future<ApiResult<List<Project>>> fetchProjects() async {
    try {
      final Response<List<dynamic>?> response = await dio.get<List<dynamic>?>(
        projectsEndpoint,
        options: Options(
          headers: dioConfig.headers,
        ),
      );
      final List<dynamic>? data = response.data;
      if (data == null) {
        return const ApiResult<List<Project>>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }
      final List<Project> projects = data
          .map((dynamic project) =>
              Project.fromJson(project as Map<String, dynamic>))
          .toList();
      return ApiResult<List<Project>>.success(
        data: projects,
      );
    } on Exception catch (e) {
      return ApiResult<List<Project>>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }

  Future<ApiResult<List<Project>>> fetchInvitedProjects() async {
    try {
      final Response<List<dynamic>?> response = await dio.get<List<dynamic>?>(
        invitedProjectsEndpoint,
        options: Options(
          headers: dioConfig.headers,
        ),
      );
      final List<dynamic>? data = response.data;
      if (data == null) {
        return const ApiResult<List<Project>>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }
      final List<Project> projects = data
          .map((dynamic project) =>
              Project.fromJson(project as Map<String, dynamic>))
          .toList();
      return ApiResult<List<Project>>.success(
        data: projects,
      );
    } on Exception catch (e) {
      return ApiResult<List<Project>>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }

  Future<ApiResult<void>> createProject({
    required Map<String, dynamic> projectData,
  }) async {
    try {
      await dio.post<void>(
        createProjectEndpoint,
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
}
