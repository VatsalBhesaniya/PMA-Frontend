import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/project.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';

class ProjectsRepository {
  ProjectsRepository({
    required this.dioClient,
  });
  final DioClient dioClient;

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
}
