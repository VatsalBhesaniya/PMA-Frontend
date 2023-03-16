import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:http_mock_adapter/src/handlers/request_handler.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/note.dart';
import 'package:pma/module/Notes/notes_repository.dart';
import 'package:pma/module/notes/bloc/notes_bloc.dart';
import 'package:pma/utils/network_exceptions.dart';

void main() {
  group('Note Bloc', () {
    late Dio dio;
    late DioAdapter dioAdapter;
    late NotesBloc notesBloc;
    const int projectId = 1;
    const int noteId = 1;
    const String fetchNotesUrl = '$projectNotesEndpoint/$projectId';
    const String deleteNoteUrl = '$notesEndpoint/$noteId';
    final Note note = Note(
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
    final List<dynamic> data = <dynamic>[note.toJson()];

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
      notesBloc = NotesBloc(
        notesRepository: NotesRepository(
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
      'Fetch Notes',
      () {
        blocTest<NotesBloc, NotesState>(
          'Success',
          setUp: () {
            return dioAdapter.onGet(
              fetchNotesUrl,
              (MockServer request) => request.reply(200, data),
            );
          },
          build: () => notesBloc,
          act: (NotesBloc bloc) => bloc.add(
            const NotesEvent.fetchNotes(projectId: projectId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <NotesState>[
            const NotesState.loadInProgress(),
            NotesState.fetchNotesSuccess(
              notes: <Note>[note],
            ),
          ],
        );

        blocTest<NotesBloc, NotesState>(
          'Failure',
          setUp: () {
            return dioAdapter.onGet(
              fetchNotesUrl,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => notesBloc,
          act: (NotesBloc bloc) => bloc.add(
            const NotesEvent.fetchNotes(projectId: projectId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <NotesState>[
            const NotesState.loadInProgress(),
            const NotesState.fetchNotesFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );

    group(
      'Delete Note',
      () {
        blocTest<NotesBloc, NotesState>(
          'Success',
          setUp: () {
            return dioAdapter.onDelete(
              deleteNoteUrl,
              (MockServer request) => request.reply(204, null),
            );
          },
          build: () => notesBloc,
          act: (NotesBloc bloc) => bloc.add(
            const NotesEvent.deleteNote(noteId: noteId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <NotesState>[
            const NotesState.loadInProgress(),
            const NotesState.deleteNoteSuccess(),
          ],
        );

        blocTest<NotesBloc, NotesState>(
          'Failure',
          setUp: () {
            return dioAdapter.onDelete(
              deleteNoteUrl,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => notesBloc,
          act: (NotesBloc bloc) => bloc.add(
            const NotesEvent.deleteNote(noteId: noteId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <NotesState>[
            const NotesState.loadInProgress(),
            const NotesState.deleteNoteFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );
  });
}
