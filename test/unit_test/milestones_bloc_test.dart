import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:http_mock_adapter/src/handlers/request_handler.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/constants/enum.dart';
import 'package:pma/models/milestone.dart';
import 'package:pma/models/roadmap.dart';
import 'package:pma/module/milestones/bloc/milestones_bloc.dart';
import 'package:pma/module/milestones/milestones_repository.dart';
import 'package:pma/utils/network_exceptions.dart';

void main() {
  group('Milestones Bloc', () {
    late Dio dio;
    late DioAdapter dioAdapter;
    late MilestonesBloc milestonesBloc;
    const int milestoneId = 1;
    const int projectId = 1;
    const String fetchMilestonesUrl = '$projectMilestonesEndpoint/$projectId';
    final Milestone milestone = Milestone(
      id: milestoneId,
      projectId: projectId,
      title: 'title',
      completionDate: '2023-03-16T02:51:10.577757+05:30',
      description: <dynamic>[],
      descriptionPlainText: '',
      isCompleted: false,
    );
    final Roadmap roadmap = Roadmap(
      milestones: <Milestone>[milestone],
      currentUserRole: MemberRole.member.index + 1,
    );
    final Map<String, dynamic> roadmapData = roadmap.toJson();

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
      milestonesBloc = MilestonesBloc(
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
      'Fetch Milestones',
      () {
        blocTest<MilestonesBloc, MilestonesState>(
          'Success',
          setUp: () {
            return dioAdapter.onGet(
              fetchMilestonesUrl,
              (MockServer request) => request.reply(200, roadmapData),
            );
          },
          build: () => milestonesBloc,
          act: (MilestonesBloc bloc) => bloc.add(
            const MilestonesEvent.fetchMilestones(projectId: projectId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <MilestonesState>[
            const MilestonesState.loadInProgress(),
            MilestonesState.fetchMilestoneSuccess(
              roadmap: Roadmap.fromJson(roadmapData),
            ),
          ],
        );

        blocTest<MilestonesBloc, MilestonesState>(
          'Failure',
          setUp: () {
            return dioAdapter.onGet(
              fetchMilestonesUrl,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => milestonesBloc,
          act: (MilestonesBloc bloc) => bloc.add(
            const MilestonesEvent.fetchMilestones(projectId: projectId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <MilestonesState>[
            const MilestonesState.loadInProgress(),
            const MilestonesState.fetchMilestoneFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );
  });
}
