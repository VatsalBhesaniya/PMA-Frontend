import 'package:dio/dio.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/note.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

class NoteRepository {
  NoteRepository({
    required this.dioConfig,
    required this.dio,
  });
  final DioConfig dioConfig;
  final Dio dio;

  Future<ApiResult<Note>> fetchNote({
    required int noteId,
  }) async {
    try {
      final Response<Map<String, dynamic>?> response =
          await dio.get<Map<String, dynamic>?>(
        '$notesEndpoint/$noteId',
        options: Options(
          headers: dioConfig.headers,
        ),
      );
      final Map<String, dynamic>? data = response.data;
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

  Future<ApiResult<Note>> updateNote({
    required Note note,
  }) async {
    try {
      final Response<Map<String, dynamic>?> response =
          await dio.put<Map<String, dynamic>?>(
        '$notesEndpoint/${note.id}',
        options: Options(
          headers: dioConfig.headers,
        ),
        data: note.toJson()
          ..remove('id')
          ..remove('created_by'),
      );
      final Map<String, dynamic>? data = response.data;
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

  Future<ApiResult<void>> deleteNote({
    required int noteId,
  }) async {
    try {
      final Response<void> response = await dio.delete<void>(
        '$notesEndpoint/$noteId',
        options: Options(
          headers: dioConfig.headers,
        ),
      );
      if (response.statusCode == 204) {
        return const ApiResult<void>.success(
          data: null,
        );
      }
      return const ApiResult<void>.failure(
        error: NetworkExceptions.defaultError(),
      );
    } on Exception catch (e) {
      return ApiResult<void>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }
}
