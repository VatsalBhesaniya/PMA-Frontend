import 'package:dio/dio.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/note.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

class CreateNoteRepository {
  CreateNoteRepository({
    required this.dioConfig,
    required this.dio,
  });
  final DioConfig dioConfig;
  final Dio dio;

  Future<ApiResult<int>> createNote({
    required Map<String, dynamic> noteData,
  }) async {
    try {
      final Response<Map<String, dynamic>?> response =
          await dio.post<Map<String, dynamic>?>(
        createNotesEndpoint,
        options: Options(
          headers: dioConfig.headers,
        ),
        data: noteData,
      );
      final Map<String, dynamic>? data = response.data;
      if (data == null) {
        return const ApiResult<int>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }
      return ApiResult<int>.success(
        data: Note.fromJson(data).id,
      );
    } on Exception catch (e) {
      return ApiResult<int>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }
}
