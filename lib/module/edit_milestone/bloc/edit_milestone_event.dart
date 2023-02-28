part of 'edit_milestone_bloc.dart';

@freezed
class EditMilestoneEvent with _$EditMilestoneEvent {
  const factory EditMilestoneEvent.fetchMilestone({
    required int milestoneId,
  }) = _FetchMilestone;
  const factory EditMilestoneEvent.updateMilestone({
    required int milestoneId,
    required CreateMilestone milestone,
  }) = _UpdateMilestone;
  const factory EditMilestoneEvent.deleteMilestone({
    required int milestoneId,
  }) = _DeleteMilestone;
}
