import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/task.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';

class TasksRepository {
  TasksRepository({
    required this.dioClient,
  });
  final DioClient dioClient;

  Future<ApiResult<List<Task>?>> fetchTasks() async {
    try {
      final List<dynamic>? data = await dioClient.request<List<dynamic>?>(
        url: tasksEndpoint,
        httpMethod: HttpMethod.get,
      );
      final List<Task>? tasks = data
          ?.map((dynamic task) => Task.fromJson(task as Map<String, dynamic>))
          .toList();
      return ApiResult<List<Task>?>.success(
        data: tasks,
      );
    } on Exception catch (e) {
      return ApiResult<List<Task>?>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }
}
