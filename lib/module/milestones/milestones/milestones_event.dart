part of 'milestones_bloc.dart';

@freezed
class MilestonesEvent with _$MilestonesEvent {
  const factory MilestonesEvent.fetchMilestones({
    required int projectId,
  }) = _FetchMilestones;
}
