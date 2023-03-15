import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/task.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';

class CreateTaskRepository {
  CreateTaskRepository({
    required this.dioConfig,
    required this.dio,
  });
  final DioConfig dioConfig;
  final Dio dio;

  Future<ApiResult<int>> createTask({
    required Map<String, dynamic> taskData,
  }) async {
    try {
      final Response<Map<String, dynamic>?> response =
          await dio.post<Map<String, dynamic>?>(
        createTasksEndpoint,
        options: Options(
          headers: dioConfig.headers,
        ),
        data: taskData,
      );
      final Map<String, dynamic>? data = response.data;
      if (data == null) {
        return const ApiResult<int>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }
      return ApiResult<int>.success(
        data: Task.fromJson(data).id,
      );
    } on Exception catch (e) {
      return ApiResult<int>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }
}
