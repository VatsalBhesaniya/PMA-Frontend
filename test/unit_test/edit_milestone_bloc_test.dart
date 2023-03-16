import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:http_mock_adapter/src/handlers/request_handler.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/models/create_milestone.dart';
import 'package:pma/models/milestone.dart';
import 'package:pma/module/edit_milestone/bloc/edit_milestone_bloc.dart';
import 'package:pma/module/milestones/milestones_repository.dart';
import 'package:pma/utils/network_exceptions.dart';

void main() {
  group('Milestone Bloc', () {
    late Dio dio;
    late DioAdapter dioAdapter;
    late EditMilestoneBloc milestoneBloc;
    const int milestoneId = 1;
    const int projectId = 1;
    const String milestonesUrl = '$milestonesEndpoint/$milestoneId';
    final CreateMilestone createMilestone = CreateMilestone(
      projectId: projectId,
      title: 'title',
      description: <dynamic>[],
      descriptionPlainText: '',
      isCompleted: false,
      completionDate: '2023-03-16T02:51:10.577757+05:30',
    );
    final Milestone milestone = Milestone(
      id: milestoneId,
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
      milestoneBloc = EditMilestoneBloc(
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
      'Fetch Milestone',
      () {
        blocTest<EditMilestoneBloc, EditMilestoneState>(
          'Success',
          setUp: () {
            return dioAdapter.onGet(
              milestonesUrl,
              (MockServer request) => request.reply(200, milestoneData),
            );
          },
          build: () => milestoneBloc,
          act: (EditMilestoneBloc bloc) => bloc.add(
            const EditMilestoneEvent.fetchMilestone(milestoneId: milestoneId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <EditMilestoneState>[
            const EditMilestoneState.loadInProgress(),
            EditMilestoneState.fetchMilestoneSuccess(
              milestone: milestone,
            ),
          ],
        );

        blocTest<EditMilestoneBloc, EditMilestoneState>(
          'Failure',
          setUp: () {
            return dioAdapter.onGet(
              milestonesUrl,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => milestoneBloc,
          act: (EditMilestoneBloc bloc) => bloc.add(
            const EditMilestoneEvent.fetchMilestone(milestoneId: milestoneId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <EditMilestoneState>[
            const EditMilestoneState.loadInProgress(),
            const EditMilestoneState.fetchMilestoneFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );

    group(
      'Update Milestone',
      () {
        blocTest<EditMilestoneBloc, EditMilestoneState>(
          'Success',
          setUp: () {
            return dioAdapter.onPut(
              milestonesUrl,
              data: Matchers.any,
              (MockServer request) => request.reply(200, milestoneData),
            );
          },
          build: () => milestoneBloc,
          act: (EditMilestoneBloc bloc) => bloc.add(
            EditMilestoneEvent.updateMilestone(
              milestone: createMilestone,
              milestoneId: milestoneId,
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <EditMilestoneState>[
            const EditMilestoneState.loadInProgress(),
            const EditMilestoneState.updateMilestoneSuccess(),
          ],
        );

        blocTest<EditMilestoneBloc, EditMilestoneState>(
          'Failure',
          setUp: () {
            return dioAdapter.onPut(
              milestonesUrl,
              data: Matchers.any,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => milestoneBloc,
          act: (EditMilestoneBloc bloc) => bloc.add(
            EditMilestoneEvent.updateMilestone(
              milestone: createMilestone,
              milestoneId: milestoneId,
            ),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <EditMilestoneState>[
            const EditMilestoneState.loadInProgress(),
            const EditMilestoneState.updateMilestoneFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );

    group(
      'Delete Milestone',
      () {
        blocTest<EditMilestoneBloc, EditMilestoneState>(
          'Success',
          setUp: () {
            return dioAdapter.onDelete(
              milestonesUrl,
              (MockServer request) => request.reply(204, null),
            );
          },
          build: () => milestoneBloc,
          act: (EditMilestoneBloc bloc) => bloc.add(
            const EditMilestoneEvent.deleteMilestone(milestoneId: milestoneId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <EditMilestoneState>[
            const EditMilestoneState.loadInProgress(),
            const EditMilestoneState.deleteMilestoneSuccess(),
          ],
        );

        blocTest<EditMilestoneBloc, EditMilestoneState>(
          'Failure',
          setUp: () {
            return dioAdapter.onDelete(
              milestonesUrl,
              (MockServer request) => request.reply(200, null),
            );
          },
          build: () => milestoneBloc,
          act: (EditMilestoneBloc bloc) => bloc.add(
            const EditMilestoneEvent.deleteMilestone(milestoneId: milestoneId),
          ),
          wait: const Duration(milliseconds: 10),
          expect: () => <EditMilestoneState>[
            const EditMilestoneState.loadInProgress(),
            const EditMilestoneState.deleteMilestoneFailure(
              error: NetworkExceptions.defaultError(),
            ),
          ],
        );
      },
    );
  });
}
