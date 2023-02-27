import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/milestone.dart';
import 'package:pma/module/milestones/milestones_repository.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

part 'milestones_state.dart';
part 'milestones_event.dart';
part 'milestones_bloc.freezed.dart';

class MilestonesBloc extends Bloc<MilestonesEvent, MilestonesState> {
  MilestonesBloc({
    required MilestonesRepository milestonesRepository,
  })  : _milestonesRepository = milestonesRepository,
        super(const MilestonesState.initial()) {
    on<_FetchMilestones>(_onFetchMilestones);
  }

  final MilestonesRepository _milestonesRepository;

  FutureOr<void> _onFetchMilestones(
      _FetchMilestones event, Emitter<MilestonesState> emit) async {
    final ApiResult<List<Milestone>> apiResult =
        await _milestonesRepository.fetchMilestones(projectId: event.projectId);
    apiResult.when(
      success: (List<Milestone> milestones) {
        emit(
          MilestonesState.fetchMilestoneSuccess(
            milestones: milestones,
          ),
        );
      },
      failure: (NetworkExceptions error) {
        emit(
          MilestonesState.fetchMilestoneFailure(
            error: error,
          ),
        );
      },
    );
  }
}
