import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/document.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';

class DocumentRepository {
  DocumentRepository({
    required this.dioClient,
  });
  final DioClient dioClient;

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

  Future<ApiResult<Document>> updateDocument({
    required Document document,
  }) async {
    try {
      final Map<String, dynamic>? data =
          await dioClient.request<Map<String, dynamic>?>(
        url: '$documentsEndpoint/${document.id}',
        httpMethod: HttpMethod.put,
        data: document.toJson()
          ..remove('id')
          ..remove('created_by'),
      );
      if (data == null) {
        return const ApiResult<Document>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }
      return ApiResult<Document>.success(
        data: Document.fromJson(data),
      );
    } on Exception catch (e) {
      return ApiResult<Document>.failure(
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
