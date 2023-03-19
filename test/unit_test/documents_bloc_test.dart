import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:http_mock_adapter/src/handlers/request_handler.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/document.dart';
import 'package:pma/module/Documents/bloc/documents_bloc.dart';
import 'package:pma/module/Documents/documents_repository.dart';
import 'package:pma/utils/network_exceptions.dart';

void main() {
  group('Documents Bloc', () {
    late Dio dio;
    late DioAdapter dioAdapter;
    late DocumentsBloc documentsBloc;
    const int projectId = 1;
    const int documentId = 1;
    const String fetchDocumentsUrl = '$projectDocumentsEndpoint/$projectId';
    const String deleteDocumentUrl = '$documentsEndpoint/$documentId';
    final Document document = Document(
      id: 59,
      projectId: 50,
      title: 'Test Title',
      content: <dynamic>[
        <String, dynamic>{'insert': 'Test Description'}
      ],
      contentPlainText: 'Test Description',
      createdBy: 1,
      createdAt: '2023-03-16T02:51:10.577757+05:30',
      currentUserRole: 4,
      isExpanded: false,
      isEdit: false,
      isSelected: false,
    );
    final List<dynamic> data = <dynamic>[document.toJson()];

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
      documentsBloc = DocumentsBloc(
        documentsRepository: DocumentsRepository(
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
      'Fetch Documents',
      () {
        blocTest<DocumentsBloc, DocumentsState>(
          'Success',
          setUp: () {
            return dioAdapter.onGet(
              fetchDocumentsUrl,
              (MockServer request) => request.reply(200, data),
            );
          },
          build: () => documentsBloc,
          act: (DocumentsBloc bloc) => bloc.add(
            const DocumentsEvent.fetchDocuments(projectId: projectId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <DocumentsState>[
            const DocumentsState.loadInProgress(),
            DocumentsState.fetchDocumentsSuccess(
              documents: <Document>[document],
            ),
          ],
        );

        blocTest<DocumentsBloc, DocumentsState>(
          'Failure',
          setUp: () {
            return dioAdapter.onGet(
              fetchDocumentsUrl,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => documentsBloc,
          act: (DocumentsBloc bloc) => bloc.add(
            const DocumentsEvent.fetchDocuments(projectId: projectId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <DocumentsState>[
            const DocumentsState.loadInProgress(),
            const DocumentsState.fetchDocumentsFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );

    group(
      'Delete Document',
      () {
        blocTest<DocumentsBloc, DocumentsState>(
          'Success',
          setUp: () {
            return dioAdapter.onDelete(
              deleteDocumentUrl,
              (MockServer request) => request.reply(204, null),
            );
          },
          build: () => documentsBloc,
          act: (DocumentsBloc bloc) => bloc.add(
            const DocumentsEvent.deleteDocument(documentId: documentId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <DocumentsState>[
            const DocumentsState.loadInProgress(),
            const DocumentsState.deleteDocumentSuccess(),
          ],
        );

        blocTest<DocumentsBloc, DocumentsState>(
          'Failure',
          setUp: () {
            return dioAdapter.onDelete(
              deleteDocumentUrl,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => documentsBloc,
          act: (DocumentsBloc bloc) => bloc.add(
            const DocumentsEvent.deleteDocument(documentId: documentId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <DocumentsState>[
            const DocumentsState.loadInProgress(),
            const DocumentsState.deleteDocumentFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );
  });
}
