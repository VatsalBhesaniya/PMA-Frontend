import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/note.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';

class NotesRepository {
  NotesRepository({
    required this.dioConfig,
    required this.dio,
  });
  final DioConfig dioConfig;
  final Dio dio;

  Future<ApiResult<List<Note>>> fetchNotes({
    required int projectId,
  }) async {
    try {
      final Response<List<dynamic>?> response = await dio.get<List<dynamic>?>(
        '$projectNotesEndpoint/$projectId',
        options: Options(
          headers: dioConfig.headers,
        ),
      );
      final List<dynamic>? data = response.data;
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

  Future<ApiResult<void>> deleteNote({
    required int noteId,
  }) async {
    try {
      await dio.delete<void>(
        '$notesEndpoint/$noteId',
        options: Options(
          headers: dioConfig.headers,
        ),
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
