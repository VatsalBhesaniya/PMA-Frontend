import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:http_mock_adapter/src/handlers/request_handler.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/create_document.dart';
import 'package:pma/models/document.dart';
import 'package:pma/module/create_document/bloc/create_document_bloc.dart';
import 'package:pma/module/create_document/create_document_repository.dart';
import 'package:pma/utils/network_exceptions.dart';

void main() {
  group('Create Document Bloc', () {
    late Dio dio;
    late DioAdapter dioAdapter;
    late CreateDocumentBloc createDocumentBloc;
    const int noteId = 1;
    const int projectId = 1;
    const String createDocumentUrl = createDocumentsEndpoint;
    final CreateDocument createDocument = CreateDocument(
      projectId: projectId,
      title: 'title',
    );
    final Map<String, dynamic> createDocumentData = createDocument.toJson();
    final Document document = Document(
      id: noteId,
      projectId: projectId,
      title: 'title',
      createdAt: '2023-03-16T02:51:10.577757+05:30',
    );
    final Map<String, dynamic> documentData = document.toJson();

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
      createDocumentBloc = CreateDocumentBloc(
        createDocumentRepository: CreateDocumentRepository(
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
      'Create Document',
      () {
        blocTest<CreateDocumentBloc, CreateDocumentState>(
          'Success',
          setUp: () {
            return dioAdapter.onPost(
              createDocumentUrl,
              data: createDocumentData,
              (MockServer request) => request.reply(200, documentData),
            );
          },
          build: () => createDocumentBloc,
          act: (CreateDocumentBloc bloc) => bloc.add(
            CreateDocumentEvent.createDocument(document: createDocument),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <CreateDocumentState>[
            const CreateDocumentState.loadInProgress(),
            CreateDocumentState.createDocumentSuccess(
              documentId: Document.fromJson(documentData).id,
            ),
          ],
        );

        blocTest<CreateDocumentBloc, CreateDocumentState>(
          'Failure',
          setUp: () {
            return dioAdapter.onPost(
              createDocumentUrl,
              data: createDocumentData,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => createDocumentBloc,
          act: (CreateDocumentBloc bloc) => bloc.add(
            CreateDocumentEvent.createDocument(document: createDocument),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <CreateDocumentState>[
            const CreateDocumentState.loadInProgress(),
            const CreateDocumentState.createDocumentFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );
  });
}
