import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:pma/config/http_client_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/document.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

class CreateDocumentRepository {
  CreateDocumentRepository({
    required this.httpClient,
  });

  final HttpClientConfig httpClient;

  Future<ApiResult<int>> createDocument({
    required Map<String, dynamic> documentData,
  }) async {
    try {
      final http.Response response = await http.post(
        Uri.parse('${httpClient.baseUrl}$documentsEndpoint/create'),
        headers: <String, String>{
          HttpHeaders.authorizationHeader: httpClient.token,
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(documentData),
      );
      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse =
            jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResult<int>.success(
          data: Document.fromJson(jsonResponse).id,
        );
      } else {
        return const ApiResult<int>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }

      // final Map<String, dynamic>? data =
      //     await dioClient.request<Map<String, dynamic>?>(
      //   url: 'documentsEndpoint/create',
      //   httpMethod: HttpMethod.post,
      //   data: FormData.fromMap(documentData),
      // );
      // return ApiResult<int>.success(
      //   data: data != null ? Document.fromJson(data).id : null,
      // );
    } on Exception catch (e) {
      return ApiResult<int>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }
}
