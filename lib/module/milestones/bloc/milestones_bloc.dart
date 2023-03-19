import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/roadmap.dart';
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
    emit(const MilestonesState.loadInProgress());
    final ApiResult<Roadmap> apiResult =
        await _milestonesRepository.fetchMilestones(projectId: event.projectId);
    apiResult.when(
      success: (Roadmap roadmap) {
        emit(
          MilestonesState.fetchMilestoneSuccess(
            roadmap: roadmap,
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
