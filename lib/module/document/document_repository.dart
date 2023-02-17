import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:pma/config/http_client_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/document.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';

class DocumentRepository {
  DocumentRepository({
    required this.dioClient,
    required this.httpClient,
  });
  final DioClient dioClient;
  final HttpClientConfig httpClient;

  Future<ApiResult<Document?>> fetchDocument({
    required int documentId,
  }) async {
    try {
      final Map<String, dynamic>? data =
          await dioClient.request<Map<String, dynamic>?>(
        url: '$documentsEndpoint/$documentId',
        httpMethod: HttpMethod.get,
      );
      return ApiResult<Document?>.success(
        data: Document.fromJson(data!),
      );
    } on Exception catch (e) {
      return ApiResult<Document?>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }

  Future<ApiResult<Document?>> updateDocument({
    required Document document,
  }) async {
    try {
      final String body = jsonEncode(document.toJson()
        ..remove('id')
        ..remove('created_by'));
      final String? token =
          await const FlutterSecureStorage().read(key: 'token');
      final http.Response response = await http.put(
        Uri.parse('${httpClient.baseUrl}$documentsEndpoint/${document.id}'),
        headers: <String, String>{
          HttpHeaders.authorizationHeader: token!,
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse =
            jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResult<Document?>.success(
          data: Document.fromJson(jsonResponse),
        );
      } else {
        return ApiResult<Document?>.failure(
          error: NetworkExceptions.dioException(
            Exception('Something went wrong!'),
          ),
        );
      }

      // final Map<String, dynamic>? data =
      //     await dioClient.request<Map<String, dynamic>?>(
      //   url: '$notesEndpoint/${document.id}',
      //   httpMethod: HttpMethod.put,
      //   data: FormData.fromMap(
      //     document.toJson()
      //       ..remove('id')
      //       ..remove('created_by'),
      //   ),
      // );
      // return ApiResult<Document?>.success(
      //   data: Document.fromJson(data!),
      // );
    } on Exception catch (e) {
      return ApiResult<Document?>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }

  Future<ApiResult<bool>> deleteDocument({
    required int documentId,
  }) async {
    try {
      await dioClient.request<void>(
        url: '$documentsEndpoint/$documentId',
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
