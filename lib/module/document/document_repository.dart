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
}
