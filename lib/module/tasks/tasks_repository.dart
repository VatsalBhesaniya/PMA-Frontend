import 'package:dio/dio.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/task.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

class TasksRepository {
  TasksRepository({
    required this.dioConfig,
    required this.dio,
  });
  final DioConfig dioConfig;
  final Dio dio;

  Future<ApiResult<List<Task>>> fetchTasks({
    required int projectId,
  }) async {
    try {
      final Response<List<dynamic>?> response = await dio.get<List<dynamic>?>(
        '$tasksEndpoint/project/$projectId',
        options: Options(
          headers: dioConfig.headers,
        ),
      );
      final List<dynamic>? data = response.data;
      if (data == null) {
        return const ApiResult<List<Task>>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }
      final List<Task> tasks = data
          .map((dynamic task) => Task.fromJson(task as Map<String, dynamic>))
          .toList();
      return ApiResult<List<Task>>.success(
        data: tasks,
      );
    } on Exception catch (e) {
      return ApiResult<List<Task>>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }

  Future<ApiResult<void>> deleteTask({
    required int taskId,
  }) async {
    try {
      final Response<void> response = await dio.delete<void>(
        '$tasksEndpoint/$taskId',
        options: Options(
          headers: dioConfig.headers,
        ),
      );
      if (response.statusCode == 204) {
        return const ApiResult<void>.success(
          data: null,
        );
      }
      return const ApiResult<void>.failure(
        error: NetworkExceptions.defaultError(),
      );
    } on Exception catch (e) {
      return ApiResult<void>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }
}
