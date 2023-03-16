import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:http_mock_adapter/src/handlers/request_handler.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/document.dart';
import 'package:pma/module/document/bloc/document_bloc.dart';
import 'package:pma/module/document/document_repository.dart';
import 'package:pma/utils/network_exceptions.dart';

void main() {
  group('Document Bloc', () {
    late Dio dio;
    late DioAdapter dioAdapter;
    late DocumentBloc documentBloc;
    const int documentId = 1;
    const String documentsUrl = '$documentsEndpoint/$documentId';
    final Document document = Document(
      id: 1,
      projectId: 1,
      title: 'title',
      createdAt: '2023-03-16T02:51:10.577757+05:30',
    );
    final Map<String, dynamic> data = document.toJson();

    setUp(() {
      dio = Dio(
        BaseOptions(
          baseUrl: iosBaseUrl,
          connectTimeout: const Duration(minutes: 1),
          receiveTimeout: const Duration(minutes: 1),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8'
          },
        ),
      );
      dioAdapter = DioAdapter(
        dio: dio,
        matcher: const UrlRequestMatcher(),
      );
      dio.httpClientAdapter = dioAdapter;
      documentBloc = DocumentBloc(
        documentRepository: DocumentRepository(
          dio: dio,
          dioConfig: DioConfig(
            baseUrl: iosBaseUrl,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'authorization': 'token'
            },
          ),
        ),
      );
    });

    group(
      'Fetch Document',
      () {
        blocTest<DocumentBloc, DocumentState>(
          'Success',
          setUp: () {
            return dioAdapter.onGet(
              documentsUrl,
              (MockServer request) => request.reply(200, data),
            );
          },
          build: () => documentBloc,
          act: (DocumentBloc bloc) => bloc.add(
            const DocumentEvent.fetchDocument(documentId: documentId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <DocumentState>[
            const DocumentState.loadInProgress(),
            DocumentState.fetchDocumentSuccess(
              document: document,
            ),
          ],
        );

        blocTest<DocumentBloc, DocumentState>(
          'Failure',
          setUp: () {
            return dioAdapter.onGet(
              documentsUrl,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => documentBloc,
          act: (DocumentBloc bloc) => bloc.add(
            const DocumentEvent.fetchDocument(documentId: documentId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <DocumentState>[
            const DocumentState.loadInProgress(),
            const DocumentState.fetchDocumentFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );

    group(
      'Update Document',
      () {
        blocTest<DocumentBloc, DocumentState>(
          'Success',
          setUp: () {
            return dioAdapter.onPut(
              documentsUrl,
              data: Matchers.any,
              (MockServer request) => request.reply(200, data),
            );
          },
          build: () => documentBloc,
          act: (DocumentBloc bloc) => bloc.add(
            DocumentEvent.updateDocument(document: document),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <DocumentState>[
            const DocumentState.loadInProgress(),
            DocumentState.fetchDocumentSuccess(
              document: document,
            ),
          ],
        );

        blocTest<DocumentBloc, DocumentState>(
          'Failure',
          setUp: () {
            return dioAdapter.onPut(
              documentsUrl,
              data: Matchers.any,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => documentBloc,
          act: (DocumentBloc bloc) => bloc.add(
            DocumentEvent.updateDocument(document: document),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <DocumentState>[
            const DocumentState.loadInProgress(),
            const DocumentState.updateDocumentFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );

    group(
      'Delete Document',
      () {
        blocTest<DocumentBloc, DocumentState>(
          'Success',
          setUp: () {
            return dioAdapter.onDelete(
              documentsUrl,
              (MockServer request) => request.reply(204, null),
            );
          },
          build: () => documentBloc,
          act: (DocumentBloc bloc) => bloc.add(
            const DocumentEvent.deleteDocument(documentId: documentId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <DocumentState>[
            const DocumentState.loadInProgress(),
            const DocumentState.deleteDocumentSuccess(),
          ],
        );

        blocTest<DocumentBloc, DocumentState>(
          'Failure',
          setUp: () {
            return dioAdapter.onDelete(
              documentsUrl,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => documentBloc,
          act: (DocumentBloc bloc) => bloc.add(
            const DocumentEvent.deleteDocument(documentId: documentId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <DocumentState>[
            const DocumentState.loadInProgress(),
            const DocumentState.deleteDocumentFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );
  });
}
