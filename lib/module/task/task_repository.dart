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

  Future<ApiResult<Task>> fetchTask({
    required int taskId,
  }) async {
    try {
      final Map<String, dynamic>? data =
          await dioClient.request<Map<String, dynamic>?>(
        url: '$tasksEndpoint/$taskId',
        httpMethod: HttpMethod.get,
      );
      if (data == null) {
        return const ApiResult<Task>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }
      return ApiResult<Task>.success(
        data: Task.fromJson(data),
      );
    } on Exception catch (e) {
      return ApiResult<Task>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }

  Future<ApiResult<Task>> updateTask({
    required Task task,
  }) async {
    try {
      final Map<String, dynamic>? data =
          await dioClient.request<Map<String, dynamic>?>(
        url: '$tasksEndpoint/${task.id}',
        httpMethod: HttpMethod.put,
        data: task.toJson()
          ..remove('id')
          ..remove('created_by'),
      );
      if (data == null) {
        return const ApiResult<Task>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }
      return ApiResult<Task>.success(
        data: Task.fromJson(data),
      );
    } on Exception catch (e) {
      return ApiResult<Task>.failure(
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
      await dioClient.request<void>(
        url: '$assignTasksEndpoint/$taskId',
        httpMethod: HttpMethod.post,
        data: membersData,
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
      await dioClient.request<void>(
        url: attachNotesEndpoint,
        httpMethod: HttpMethod.post,
        data: notesData,
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

  Future<ApiResult<void>> removeAttachedNote({
    required int taskId,
    required int noteId,
  }) async {
    try {
      await dioClient.request<void>(
        url: '$attachNotesEndpoint/$taskId/$noteId',
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

  Future<ApiResult<void>> attachDocuments({
    required List<Map<String, dynamic>> documentsData,
  }) async {
    try {
      await dioClient.request<void>(
        url: attachDocumentsEndpoint,
        httpMethod: HttpMethod.post,
        data: documentsData,
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

  Future<ApiResult<void>> removeAttachedDocument({
    required int taskId,
    required int documentId,
  }) async {
    try {
      await dioClient.request<void>(
        url: '$attachDocumentsEndpoint/$taskId/$documentId',
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
