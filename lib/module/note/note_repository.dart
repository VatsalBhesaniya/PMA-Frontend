import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:pma/config/http_client_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/note.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';

class NoteRepository {
  NoteRepository({
    required this.dioClient,
    required this.httpClient,
  });
  final DioClient dioClient;
  final HttpClientConfig httpClient;

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

  Future<ApiResult<Note?>> updateNote({
    required Note note,
  }) async {
    try {
      final String body = jsonEncode(note.toJson()
        ..remove('id')
        ..remove('created_by'));
      final String? token =
          await const FlutterSecureStorage().read(key: 'token');
      final http.Response response = await http.put(
        Uri.parse('${httpClient.baseUrl}$notesEndpoint/${note.id}'),
        headers: <String, String>{
          HttpHeaders.authorizationHeader: token!,
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse =
            jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResult<Note?>.success(
          data: Note.fromJson(jsonResponse),
        );
      } else {
        return ApiResult<Note?>.failure(
          error: NetworkExceptions.dioException(
            Exception('Something went wrong!'),
          ),
        );
      }

      // final Map<String, dynamic>? data =
      //     await dioClient.request<Map<String, dynamic>?>(
      //   url: '$notesEndpoint/${note.id}',
      //   httpMethod: HttpMethod.put,
      //   data: FormData.fromMap(
      //     note.toJson()
      //       ..remove('id')
      //       ..remove('created_by'),
      //   ),
      // );
      // return ApiResult<Note?>.success(
      //   data: Note.fromJson(data!),
      // );
    } on Exception catch (e) {
      return ApiResult<Note?>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }
}
