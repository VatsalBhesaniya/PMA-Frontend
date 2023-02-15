import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/document.dart';
import 'package:pma/models/note.dart';
import 'package:pma/models/task.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';

class TaskRepository {
  TaskRepository({
    required this.dioClient,
  });
  final DioClient dioClient;

  Future<ApiResult<Task?>> fetchTask({
    required int taskId,
  }) async {
    try {
      final Map<String, dynamic>? data =
          await dioClient.request<Map<String, dynamic>?>(
        url: '$tasksEndpoint/$taskId',
        httpMethod: HttpMethod.get,
      );
      return ApiResult<Task?>.success(
        data: Task.fromJson(data!),
      );
    } on Exception catch (e) {
      return ApiResult<Task?>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }

  Future<ApiResult<List<Note>?>> fetchAttachedNotes({
    required List<int> noteIds,
  }) async {
    try {
      String queryParams = noteIds.isEmpty ? '' : '?';
      for (final int id in noteIds) {
        queryParams += 'noteId=$id&';
      }
      final List<dynamic>? data = await dioClient.request<List<dynamic>?>(
        url: '$notesEndpoint/attached$queryParams',
        httpMethod: HttpMethod.get,
      );
      final List<Note>? notes = data
          ?.map((dynamic note) => Note.fromJson(note as Map<String, dynamic>))
          .toList();
      return ApiResult<List<Note>?>.success(
        data: notes,
      );
    } on Exception catch (e) {
      return ApiResult<List<Note>?>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }

  Future<ApiResult<List<Document>?>> fetchAttachedDocuments({
    required List<int> documentIds,
  }) async {
    try {
      String queryParams = documentIds.isEmpty ? '' : '?';
      for (final int id in documentIds) {
        queryParams += 'documentId=$id&';
      }
      final List<dynamic>? data = await dioClient.request<List<dynamic>?>(
        url: '$documentsEndpoint/attached$queryParams',
        httpMethod: HttpMethod.get,
      );
      final List<Document>? documents = data
          ?.map((dynamic document) =>
              Document.fromJson(document as Map<String, dynamic>))
          .toList();
      return ApiResult<List<Document>?>.success(
        data: documents,
      );
    } on Exception catch (e) {
      return ApiResult<List<Document>?>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }
}
