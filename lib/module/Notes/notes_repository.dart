import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/note.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';

class NotesRepository {
  NotesRepository({
    required this.dioClient,
  });
  final DioClient dioClient;

  Future<ApiResult<List<Note>?>> fetchNotes() async {
    try {
      final List<dynamic>? data = await dioClient.request<List<dynamic>?>(
        url: notesEndpoint,
        httpMethod: HttpMethod.get,
      );
      final List<Note>? tasks = data
          ?.map((dynamic task) => Note.fromJson(task as Map<String, dynamic>))
          .toList();
      return ApiResult<List<Note>?>.success(
        data: tasks,
      );
    } on Exception catch (e) {
      return ApiResult<List<Note>?>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }
}
