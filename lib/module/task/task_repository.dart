import 'package:dio/dio.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/document.dart';
import 'package:pma/models/note.dart';
import 'package:pma/models/task.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

class TaskRepository {
  TaskRepository({
    required this.dioConfig,
    required this.dio,
  });
  final DioConfig dioConfig;
  final Dio dio;

  Future<ApiResult<Task>> fetchTask({
    required int taskId,
  }) async {
    try {
      final Response<Map<String, dynamic>?> response =
          await dio.get<Map<String, dynamic>?>(
        '$tasksEndpoint/$taskId',
        options: Options(
          headers: dioConfig.headers,
        ),
      );
      final Map<String, dynamic>? data = response.data;
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
      final Response<Map<String, dynamic>?> response =
          await dio.put<Map<String, dynamic>?>(
        '$tasksEndpoint/${task.id}',
        options: Options(
          headers: dioConfig.headers,
        ),
        data: task.toJson()
          ..remove('id')
          ..remove('created_by'),
      );
      final Map<String, dynamic>? data = response.data;
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

  Future<ApiResult<void>> deleteTask({
    required int taskId,
  }) async {
    try {
      await dio.delete<void>(
        '$tasksEndpoint/$taskId',
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

  Future<ApiResult<List<Note>>> fetchAttachedNotes({
    required List<int> noteIds,
  }) async {
    try {
      String queryParams = noteIds.isEmpty ? '' : '?';
      for (final int id in noteIds) {
        queryParams += 'noteId=$id&';
      }
      final Response<List<dynamic>?> response = await dio.get<List<dynamic>?>(
        '$notesEndpoint/attached$queryParams',
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
      final Response<List<dynamic>?> response = await dio.get<List<dynamic>?>(
        '$documentsEndpoint/attached$queryParams',
        options: Options(
          headers: dioConfig.headers,
        ),
      );
      final List<dynamic>? data = response.data;
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
      await dio.post<void>(
        '$assignTasksEndpoint/$taskId',
        options: Options(
          headers: dioConfig.headers,
        ),
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
      await dio.delete<void>(
        '$assignTasksEndpoint/$taskId/$projectId/$userId',
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

  Future<ApiResult<void>> attachNotes({
    required List<Map<String, dynamic>> notesData,
  }) async {
    try {
      await dio.post<void>(
        attachNotesEndpoint,
        options: Options(
          headers: dioConfig.headers,
        ),
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
      await dio.delete<void>(
        '$attachNotesEndpoint/$taskId/$noteId',
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

  Future<ApiResult<void>> attachDocuments({
    required List<Map<String, dynamic>> documentsData,
  }) async {
    try {
      await dio.post<void>(
        attachDocumentsEndpoint,
        options: Options(
          headers: dioConfig.headers,
        ),
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
      await dio.delete<void>(
        '$attachDocumentsEndpoint/$taskId/$documentId',
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

  Future<ApiResult<List<Note>>> fetchProjectNotes({
    required int taskId,
    required int projectId,
  }) async {
    try {
      final Response<List<dynamic>?> response = await dio.get<List<dynamic>?>(
        '$projectNotesEndpoint/$taskId/$projectId',
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
      final Response<List<dynamic>?> response = await dio.get<List<dynamic>?>(
        '$projectDocumentsEndpoint/$taskId/$projectId',
        options: Options(
          headers: dioConfig.headers,
        ),
      );
      final List<dynamic>? data = response.data;
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
