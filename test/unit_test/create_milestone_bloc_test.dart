import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:http_mock_adapter/src/handlers/request_handler.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/create_milestone.dart';
import 'package:pma/models/milestone.dart';
import 'package:pma/module/create_milestone/bloc/create_milestone_bloc.dart';
import 'package:pma/module/milestones/milestones_repository.dart';
import 'package:pma/utils/network_exceptions.dart';

void main() {
  group('Create Milestone Bloc', () {
    late Dio dio;
    late DioAdapter dioAdapter;
    late CreateMilestoneBloc createMilestoneBloc;
    const int noteId = 1;
    const int projectId = 1;
    const String createMilestoneUrl = createMilestonesEndpoint;
    final CreateMilestone createMilestone = CreateMilestone(
      projectId: projectId,
      title: 'title',
      description: <dynamic>[],
      descriptionPlainText: '',
      isCompleted: false,
      completionDate: '2023-03-16T02:51:10.577757+05:30',
    );
    final Map<String, dynamic> createMilestoneData = createMilestone.toJson();
    final Milestone milestone = Milestone(
      id: noteId,
      projectId: projectId,
      title: 'title',
      completionDate: '2023-03-16T02:51:10.577757+05:30',
      description: <dynamic>[],
      descriptionPlainText: '',
      isCompleted: false,
    );
    final Map<String, dynamic> milestoneData = milestone.toJson();

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
      createMilestoneBloc = CreateMilestoneBloc(
        milestonesRepository: MilestonesRepository(
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
      'Create Milestone',
      () {
        blocTest<CreateMilestoneBloc, CreateMilestoneState>(
          'Success',
          setUp: () {
            return dioAdapter.onPost(
              createMilestoneUrl,
              data: createMilestoneData,
              (MockServer request) => request.reply(200, milestoneData),
            );
          },
          build: () => createMilestoneBloc,
          act: (CreateMilestoneBloc bloc) => bloc.add(
            CreateMilestoneEvent.createMilestone(milestone: createMilestone),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <CreateMilestoneState>[
            const CreateMilestoneState.loadInProgress(),
            const CreateMilestoneState.createMilestoneSuccess(),
          ],
        );

        blocTest<CreateMilestoneBloc, CreateMilestoneState>(
          'Failure',
          setUp: () {
            return dioAdapter.onPost(
              createMilestoneUrl,
              data: createMilestoneData,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => createMilestoneBloc,
          act: (CreateMilestoneBloc bloc) => bloc.add(
            CreateMilestoneEvent.createMilestone(milestone: createMilestone),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <CreateMilestoneState>[
            const CreateMilestoneState.loadInProgress(),
            const CreateMilestoneState.createMilestoneFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );
  });
}
