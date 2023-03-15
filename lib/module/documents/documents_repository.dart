import 'package:dio/dio.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/document.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

class DocumentsRepository {
  DocumentsRepository({
    required this.dioConfig,
    required this.dio,
  });
  final DioConfig dioConfig;
  final Dio dio;

  Future<ApiResult<List<Document>>> fetchDocuments({
    required int projectId,
  }) async {
    try {
      final Response<List<dynamic>?> response = await dio.get<List<dynamic>?>(
        '$projectDocumentsEndpoint/$projectId',
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
      documents.sort(
        (Document a, Document b) => b.createdAt.compareTo(a.createdAt),
      );
      return ApiResult<List<Document>>.success(
        data: documents,
      );
    } on Exception catch (e) {
      return ApiResult<List<Document>>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }

  Future<ApiResult<void>> deleteDocument({
    required int documentId,
  }) async {
    try {
      await dio.delete<void>(
        '$documentsEndpoint/$documentId',
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
}
