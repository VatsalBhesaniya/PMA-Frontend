import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/task.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';

class CreateTaskRepository {
  CreateTaskRepository({
    required this.dioClient,
  });

  final DioClient dioClient;

  Future<ApiResult<int>> createTask({
    required Map<String, dynamic> taskData,
  }) async {
    try {
      final Map<String, dynamic>? data =
          await dioClient.request<Map<String, dynamic>?>(
        url: createTasksEndpoint,
        httpMethod: HttpMethod.post,
        data: taskData,
      );
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
