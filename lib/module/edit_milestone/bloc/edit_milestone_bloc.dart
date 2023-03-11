import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/create_milestone.dart';
import 'package:pma/models/milestone.dart';
import 'package:pma/module/milestones/milestones_repository.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

part 'edit_milestone_state.dart';
part 'edit_milestone_event.dart';
part 'edit_milestone_bloc.freezed.dart';

class EditMilestoneBloc extends Bloc<EditMilestoneEvent, EditMilestoneState> {
  EditMilestoneBloc({
    required MilestonesRepository milestonesRepository,
  })  : _milestonesRepository = milestonesRepository,
        super(const EditMilestoneState.initial()) {
    on<_FetchMilestone>(_onFetchMilestone);
    on<_EditMilestone>(_onEditMilestone);
    on<_UpdateMilestone>(_onUpdateMilestone);
    on<_DeleteMilestone>(_onDeleteMilestone);
  }

  final MilestonesRepository _milestonesRepository;

  FutureOr<void> _onFetchMilestone(
      _FetchMilestone event, Emitter<EditMilestoneState> emit) async {
    final ApiResult<Milestone> apiResult =
        await _milestonesRepository.fetchMilestone(
      milestoneId: event.milestoneId,
    );
    apiResult.when(
      success: (Milestone milestone) {
        emit(
          EditMilestoneState.fetchMilestoneSuccess(
            milestone: milestone,
          ),
        );
      },
      failure: (NetworkExceptions error) {
        emit(
          EditMilestoneState.fetchMilestoneFailure(error: error),
        );
      },
    );
  }

  FutureOr<void> _onEditMilestone(
      _EditMilestone event, Emitter<EditMilestoneState> emit) {
    emit(const EditMilestoneState.loadInProgress());
    emit(
      EditMilestoneState.fetchMilestoneSuccess(
        milestone: event.milestone,
      ),
    );
  }

  FutureOr<void> _onUpdateMilestone(
      _UpdateMilestone event, Emitter<EditMilestoneState> emit) async {
    final ApiResult<Milestone> apiResult =
        await _milestonesRepository.updateMilestone(
      milestoneId: event.milestoneId,
      milestoneData: event.milestone.toJson(),
    );
    apiResult.when(
      success: (Milestone milestone) {
        emit(
          const EditMilestoneState.updateMilestoneSuccess(),
        );
      },
      failure: (NetworkExceptions error) {
        emit(
          EditMilestoneState.updateMilestoneFailure(error: error),
        );
      },
    );
  }

  FutureOr<void> _onDeleteMilestone(
      _DeleteMilestone event, Emitter<EditMilestoneState> emit) async {
    final ApiResult<void> apiResult =
        await _milestonesRepository.deleteMilestone(
      milestoneId: event.milestoneId,
    );
    apiResult.when(
      success: (void value) {
        emit(
          const EditMilestoneState.deleteMilestoneSuccess(),
        );
      },
      failure: (NetworkExceptions error) {
        emit(
          EditMilestoneState.deleteMilestoneFailure(
            error: error,
          ),
        );
      },
    );
  }
}
