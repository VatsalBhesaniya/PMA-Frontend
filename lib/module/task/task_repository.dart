import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pma/config/http_client_config.dart';
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
    required this.httpClient,
  });
  final DioClient dioClient;
  final HttpClientConfig httpClient;

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

  Future<ApiResult<Task?>> updateTask({
    required Task task,
  }) async {
    try {
      final String body = jsonEncode(task.toJson()
        ..remove('id')
        ..remove('created_by'));
      final http.Response response = await http.put(
        Uri.parse('${httpClient.baseUrl}$tasksEndpoint/${task.id}'),
        headers: <String, String>{
          HttpHeaders.authorizationHeader: httpClient.token,
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse =
            jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResult<Task?>.success(
          data: Task.fromJson(jsonResponse),
        );
      } else {
        return const ApiResult<Task?>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }

      // final Map<String, dynamic>? data =
      //     await dioClient.request<Map<String, dynamic>?>(
      //   url: '$tasksEndpoint/${task.id}',
      //   httpMethod: HttpMethod.put,
      //   data: FormData.fromMap(
      //     task.toJson()
      //       ..remove('id')
      //       ..remove('created_by'),
      //   ),
      // );
      // return ApiResult<Task?>.success(
      //   data: Task.fromJson(data!),
      // );
    } on Exception catch (e) {
      return ApiResult<Task?>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }

  Future<ApiResult<bool>> deleteTask({
    required int taskId,
  }) async {
    try {
      await dioClient.request<void>(
        url: '$tasksEndpoint/$taskId',
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
