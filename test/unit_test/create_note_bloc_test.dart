import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:http_mock_adapter/src/handlers/request_handler.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/create_note.dart';
import 'package:pma/models/note.dart';
import 'package:pma/module/create_note/bloc/create_note_bloc.dart';
import 'package:pma/module/create_note/create_note_repository.dart';
import 'package:pma/utils/network_exceptions.dart';

void main() {
  group('Create Note Bloc', () {
    late Dio dio;
    late DioAdapter dioAdapter;
    late CreateNoteBloc createNoteBloc;
    const int noteId = 1;
    const int projectId = 1;
    const String createNoteUrl = createNotesEndpoint;
    final CreateNote createNote = CreateNote(
      projectId: projectId,
      title: 'title',
    );
    final Map<String, dynamic> createNoteData = createNote.toJson();
    final Note note = Note(
      id: noteId,
      projectId: projectId,
      title: 'title',
      createdAt: '2023-03-16T02:51:10.577757+05:30',
    );
    final Map<String, dynamic> noteData = note.toJson();

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
      createNoteBloc = CreateNoteBloc(
        createNoteRepository: CreateNoteRepository(
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
      'Create Note',
      () {
        blocTest<CreateNoteBloc, CreateNoteState>(
          'Success',
          setUp: () {
            return dioAdapter.onPost(
              createNoteUrl,
              data: createNoteData,
              (MockServer request) => request.reply(200, noteData),
            );
          },
          build: () => createNoteBloc,
          act: (CreateNoteBloc bloc) => bloc.add(
            CreateNoteEvent.createNote(note: createNote),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <CreateNoteState>[
            const CreateNoteState.loadInProgress(),
            CreateNoteState.createNoteSuccess(
              noteId: Note.fromJson(noteData).id,
            ),
          ],
        );

        blocTest<CreateNoteBloc, CreateNoteState>(
          'Failure',
          setUp: () {
            return dioAdapter.onPost(
              createNoteUrl,
              data: createNoteData,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => createNoteBloc,
          act: (CreateNoteBloc bloc) => bloc.add(
            CreateNoteEvent.createNote(note: createNote),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <CreateNoteState>[
            const CreateNoteState.loadInProgress(),
            const CreateNoteState.createNoteFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );
  });
}
