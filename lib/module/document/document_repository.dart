import 'package:dio/dio.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/document.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

class DocumentRepository {
  DocumentRepository({
    required this.dioConfig,
    required this.dio,
  });
  final DioConfig dioConfig;
  final Dio dio;

  Future<ApiResult<Document>> fetchDocument({
    required int documentId,
  }) async {
    try {
      final Response<Map<String, dynamic>?> response =
          await dio.get<Map<String, dynamic>?>(
        '$documentsEndpoint/$documentId',
        options: Options(
          headers: dioConfig.headers,
        ),
      );
      final Map<String, dynamic>? data = response.data;
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

  Future<ApiResult<Document>> updateDocument({
    required Document document,
  }) async {
    try {
      final Response<Map<String, dynamic>?> response =
          await dio.put<Map<String, dynamic>?>(
        '$documentsEndpoint/${document.id}',
        options: Options(
          headers: dioConfig.headers,
        ),
        data: document.toJson()
          ..remove('id')
          ..remove('created_by'),
      );
      final Map<String, dynamic>? data = response.data;
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

  Future<ApiResult<void>> deleteDocument({
    required int documentId,
  }) async {
    try {
      final Response<void> response = await dio.delete<void>(
        '$documentsEndpoint/$documentId',
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
