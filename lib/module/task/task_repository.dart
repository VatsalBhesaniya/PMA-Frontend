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

  Future<ApiResult<List<Note>>> fetchAttachedNotes({
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
      if (data == null) {
        return const ApiResult<List<Note>>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }
      final List<Note> notes = data
          .map((dynamic note) => Note.fromJson(note as Map<String, dynamic>))
          .toList();
      return ApiResult<List<Note>>.success(
        data: notes,
      );
    } on Exception catch (e) {
      return ApiResult<List<Note>>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }

  Future<ApiResult<List<Document>>> fetchAttachedDocuments({
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
      if (data == null) {
        return const ApiResult<List<Document>>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }
      final List<Document> documents = data
          .map((dynamic document) =>
              Document.fromJson(document as Map<String, dynamic>))
          .toList();
      return ApiResult<List<Document>>.success(
        data: documents,
      );
    } on Exception catch (e) {
      return ApiResult<List<Document>>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }

  Future<ApiResult<void>> assignTaskToMembers({
    required int taskId,
    required List<Map<String, dynamic>> membersData,
  }) async {
    try {
      final http.Response response = await http.post(
        Uri.parse('${httpClient.baseUrl}$assignTasksEndpoint/$taskId'),
        headers: <String, String>{
          HttpHeaders.authorizationHeader: httpClient.token,
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(membersData),
      );
      if (response.statusCode == 200) {
        return const ApiResult<void>.success(
          data: null,
        );
      } else {
        return const ApiResult<void>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }
    } on Exception catch (e) {
      return ApiResult<void>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }

  Future<ApiResult<void>> removeAssignedMember({
    required int taskId,
    required int projectId,
    required int userId,
  }) async {
    try {
      await dioClient.request<Map<String, dynamic>?>(
        url: '$assignTasksEndpoint/$taskId/$projectId/$userId',
        httpMethod: HttpMethod.delete,
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

  Future<ApiResult<void>> attachNotes({
    required List<Map<String, dynamic>> notesData,
  }) async {
    try {
      final http.Response response = await http.post(
        Uri.parse('${httpClient.baseUrl}$attachNotesEndpoint'),
        headers: <String, String>{
          HttpHeaders.authorizationHeader: httpClient.token,
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(notesData),
      );
      if (response.statusCode == 200) {
        return const ApiResult<void>.success(
          data: null,
        );
      } else {
        return const ApiResult<void>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }
    } on Exception catch (e) {
      return ApiResult<void>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }

  Future<ApiResult<void>> removeAttachedNote({
    required Map<String, dynamic> attachedNoteData,
  }) async {
    try {
      final http.Response response = await http.delete(
        Uri.parse('${httpClient.baseUrl}$attachNotesEndpoint'),
        headers: <String, String>{
          HttpHeaders.authorizationHeader: httpClient.token,
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(attachedNoteData),
      );
      if (response.statusCode == 204) {
        return const ApiResult<void>.success(
          data: null,
        );
      } else {
        return const ApiResult<void>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }
    } on Exception catch (e) {
      return ApiResult<void>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }

  Future<ApiResult<void>> attachDocuments({
    required List<Map<String, dynamic>> documentsData,
  }) async {
    try {
      final http.Response response = await http.post(
        Uri.parse('${httpClient.baseUrl}$attachDocumentsEndpoint'),
        headers: <String, String>{
          HttpHeaders.authorizationHeader: httpClient.token,
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(documentsData),
      );
      if (response.statusCode == 200) {
        return const ApiResult<void>.success(
          data: null,
        );
      } else {
        return const ApiResult<void>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }
    } on Exception catch (e) {
      return ApiResult<void>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }

  Future<ApiResult<void>> removeAttachedDocument({
    required Map<String, dynamic> attachedDocumentData,
  }) async {
    try {
      final http.Response response = await http.delete(
        Uri.parse('${httpClient.baseUrl}$attachDocumentsEndpoint'),
        headers: <String, String>{
          HttpHeaders.authorizationHeader: httpClient.token,
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(attachedDocumentData),
      );
      if (response.statusCode == 204) {
        return const ApiResult<void>.success(
          data: null,
        );
      } else {
        return const ApiResult<void>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }
    } on Exception catch (e) {
      return ApiResult<void>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }

  Future<ApiResult<List<Note>>> fetchProjectNotes({
    required int taskId,
    required int projectId,
  }) async {
    try {
      final List<dynamic>? data = await dioClient.request<List<dynamic>?>(
        url: '$projectNotesEndpoint/$taskId/$projectId',
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
      return ApiResult<List<Note>>.success(
        data: notes,
      );
    } on Exception catch (e) {
      return ApiResult<List<Note>>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }

  Future<ApiResult<List<Document>>> fetchProjectDocuments({
    required int taskId,
    required int projectId,
  }) async {
    try {
      final List<dynamic>? data = await dioClient.request<List<dynamic>?>(
        url: '$projectDocumentsEndpoint/$taskId/$projectId',
        httpMethod: HttpMethod.get,
      );
      if (data == null) {
        return const ApiResult<List<Document>>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }
      final List<Document> documents = data
          .map(
              (dynamic task) => Document.fromJson(task as Map<String, dynamic>))
          .toList();
      return ApiResult<List<Document>>.success(
        data: documents,
      );
    } on Exception catch (e) {
      return ApiResult<List<Document>>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }
}
