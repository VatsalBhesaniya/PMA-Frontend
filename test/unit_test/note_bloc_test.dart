import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:http_mock_adapter/src/handlers/request_handler.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/note.dart';
import 'package:pma/module/note/bloc/note_bloc.dart';
import 'package:pma/module/note/note_repository.dart';
import 'package:pma/utils/network_exceptions.dart';

void main() {
  group('Note Bloc', () {
    late Dio dio;
    late DioAdapter dioAdapter;
    late NoteBloc noteBloc;
    const int noteId = 1;
    const String notesUrl = '$notesEndpoint/$noteId';
    final Note note = Note(
      id: 1,
      projectId: 1,
      title: 'title',
      createdAt: '2023-03-16T02:51:10.577757+05:30',
    );
    final Map<String, dynamic> data = note.toJson();

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
      noteBloc = NoteBloc(
        noteRepository: NoteRepository(
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
      'Fetch Note',
      () {
        blocTest<NoteBloc, NoteState>(
          'Success',
          setUp: () {
            return dioAdapter.onGet(
              notesUrl,
              (MockServer request) => request.reply(200, data),
            );
          },
          build: () => noteBloc,
          act: (NoteBloc bloc) => bloc.add(
            const NoteEvent.fetchNote(noteId: noteId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <NoteState>[
            const NoteState.loadInProgress(),
            NoteState.fetchNoteSuccess(
              note: note,
            ),
          ],
        );

        blocTest<NoteBloc, NoteState>(
          'Failure',
          setUp: () {
            return dioAdapter.onGet(
              notesUrl,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => noteBloc,
          act: (NoteBloc bloc) => bloc.add(
            const NoteEvent.fetchNote(noteId: noteId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <NoteState>[
            const NoteState.loadInProgress(),
            const NoteState.fetchNoteFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );

    group(
      'Update Note',
      () {
        blocTest<NoteBloc, NoteState>(
          'Success',
          setUp: () {
            return dioAdapter.onPut(
              notesUrl,
              data: Matchers.any,
              (MockServer request) => request.reply(200, data),
            );
          },
          build: () => noteBloc,
          act: (NoteBloc bloc) => bloc.add(
            NoteEvent.updateNote(note: note),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <NoteState>[
            const NoteState.loadInProgress(),
            NoteState.fetchNoteSuccess(
              note: note,
            ),
          ],
        );

        blocTest<NoteBloc, NoteState>(
          'Failure',
          setUp: () {
            return dioAdapter.onPut(
              notesUrl,
              data: Matchers.any,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => noteBloc,
          act: (NoteBloc bloc) => bloc.add(
            NoteEvent.updateNote(note: note),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <NoteState>[
            const NoteState.loadInProgress(),
            const NoteState.updateNoteFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );

    group(
      'Delete Note',
      () {
        blocTest<NoteBloc, NoteState>(
          'Success',
          setUp: () {
            return dioAdapter.onDelete(
              notesUrl,
              (MockServer request) => request.reply(204, null),
            );
          },
          build: () => noteBloc,
          act: (NoteBloc bloc) => bloc.add(
            const NoteEvent.deleteNote(noteId: noteId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <NoteState>[
            const NoteState.loadInProgress(),
            const NoteState.deleteNoteSuccess(),
          ],
        );

        blocTest<NoteBloc, NoteState>(
          'Failure',
          setUp: () {
            return dioAdapter.onDelete(
              notesUrl,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => noteBloc,
          act: (NoteBloc bloc) => bloc.add(
            const NoteEvent.deleteNote(noteId: noteId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <NoteState>[
            const NoteState.loadInProgress(),
            const NoteState.deleteNoteFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );
  });
}
