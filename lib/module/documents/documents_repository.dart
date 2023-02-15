import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/document.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';

class DocumentsRepository {
  DocumentsRepository({
    required this.dioClient,
  });
  final DioClient dioClient;

  Future<ApiResult<List<Document>?>> fetchDocuments() async {
    try {
      final List<dynamic>? data = await dioClient.request<List<dynamic>?>(
        url: documentsEndpoint,
        httpMethod: HttpMethod.get,
      );
      final List<Document>? documents = data
          ?.map((dynamic document) =>
              Document.fromJson(document as Map<String, dynamic>))
          .toList();
      return ApiResult<List<Document>?>.success(
        data: documents,
      );
    } on Exception catch (e) {
      return ApiResult<List<Document>?>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }
}
