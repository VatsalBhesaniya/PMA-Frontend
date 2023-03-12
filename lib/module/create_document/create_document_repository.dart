import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/document.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';

class CreateDocumentRepository {
  CreateDocumentRepository({
    required this.dioClient,
  });

  final DioClient dioClient;

  Future<ApiResult<int>> createDocument({
    required Map<String, dynamic> documentData,
  }) async {
    try {
      final Map<String, dynamic>? data =
          await dioClient.request<Map<String, dynamic>?>(
        url: createDocumentsEndpoint,
        httpMethod: HttpMethod.post,
        data: documentData,
      );
      if (data == null) {
        return const ApiResult<int>.failure(
          error: NetworkExceptions.defaultError(),
        );
      }
      return ApiResult<int>.success(
        data: Document.fromJson(data).id,
      );
    } on Exception catch (e) {
      return ApiResult<int>.failure(
        error: NetworkExceptions.dioException(e),
      );
    }
  }
}
