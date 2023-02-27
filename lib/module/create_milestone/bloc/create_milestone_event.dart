part of 'create_milestone_bloc.dart';

@freezed
class CreateMilestoneEvent with _$CreateMilestoneEvent {
  const factory CreateMilestoneEvent.createMilestone({
    required CreateMilestone milestone,
  }) = _CreateMilestone;
}
