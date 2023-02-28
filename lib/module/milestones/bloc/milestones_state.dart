part of 'milestones_bloc.dart';

@freezed
class MilestonesState with _$MilestonesState {
  const factory MilestonesState.initial() = _Initial;
  const factory MilestonesState.loadInProgress() = _LoadInProgress;
  const factory MilestonesState.fetchMilestoneSuccess({
    required List<Milestone> milestones,
  }) = _FetchMilestoneSuccess;
  const factory MilestonesState.fetchMilestoneFailure({
    required NetworkExceptions error,
  }) = _FetchMilestoneFailure;
}
