import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/note.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';

class NoteRepository {
  NoteRepository({
    required this.dioClient,
  });
  final DioClient dioClient;

  Future<ApiResult<Note?>> fetchNote({
    required int noteId,
  }) async {
    try {
      final Map<String, dynamic>? data =
          await dioClient.request<Map<String, dynamic>?>(
        url: '$notesEndpoint/$noteId',
        httpMethod: HttpMethod.get,
      );
      return ApiResult<Note?>.success(
        data: Note.fromJson(data!),
      );
    } on Exception catch (e) {
      return ApiResult<Note?>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }

  Future<ApiResult<Note>> updateNote({
    required Note note,
  }) async {
    try {
      final Map<String, dynamic>? data =
          await dioClient.request<Map<String, dynamic>?>(
        url: '$notesEndpoint/${note.id}',
        httpMethod: HttpMethod.put,
        data: note.toJson()
          ..remove('id')
          ..remove('created_by'),
      );
      if (data == null) {
        return const ApiResult<Note>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }
      return ApiResult<Note>.success(
        data: Note.fromJson(data),
      );
    } on Exception catch (e) {
      return ApiResult<Note>.failure(
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
