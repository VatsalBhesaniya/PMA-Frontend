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

  Future<ApiResult<List<Note>>> fetchNotes({
    required int projectId,
  }) async {
    try {
      final List<dynamic>? data = await dioClient.request<List<dynamic>?>(
        url: '$projectNotesEndpoint/$projectId',
        httpMethod: HttpMethod.get,
      );
      if (data == null) {
        return const ApiResult<List<Note>>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }
      final List<Note> notes = data
          .map((dynamic task) => Note.fromJson(task as Map<String, dynamic>))
          .toList();
      notes.sort(
        (Note a, Note b) => b.createdAt.compareTo(a.createdAt),
      );
      return ApiResult<List<Note>>.success(
        data: notes,
      );
    } on Exception catch (e) {
      return ApiResult<List<Note>>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }

  Future<ApiResult<bool>> deleteNote({
    required int noteId,
  }) async {
    try {
      await dioClient.request<void>(
        url: '$notesEndpoint/$noteId',
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
