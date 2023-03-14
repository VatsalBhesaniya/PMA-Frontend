import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/create_milestone.dart';
import 'package:pma/module/milestones/milestones_repository.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

part 'create_milestone_state.dart';
part 'create_milestone_event.dart';
part 'create_milestone_bloc.freezed.dart';

class CreateMilestoneBloc
    extends Bloc<CreateMilestoneEvent, CreateMilestoneState> {
  CreateMilestoneBloc({
    required MilestonesRepository milestonesRepository,
  })  : _milestonesRepository = milestonesRepository,
        super(const CreateMilestoneState.initial()) {
    on<_CreateMilestone>(_onCreateMilestone);
  }

  final MilestonesRepository _milestonesRepository;

  FutureOr<void> _onCreateMilestone(
      _CreateMilestone event, Emitter<CreateMilestoneState> emit) async {
    final ApiResult<void> apiResult =
        await _milestonesRepository.createMilestone(
      milestoneData: event.milestone.toJson(),
    );
    apiResult.when(
      success: (void value) {
        emit(
          const CreateMilestoneState.createMilestoneSuccess(),
        );
      },
      failure: (NetworkExceptions error) {
        emit(
          CreateMilestoneState.createMilestoneFailure(error: error),
        );
      },
    );
  }
}
