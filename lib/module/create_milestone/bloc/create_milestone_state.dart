part of 'create_milestone_bloc.dart';

@freezed
class CreateMilestoneState with _$CreateMilestoneState {
  const factory CreateMilestoneState.initial() = _Initial;
  const factory CreateMilestoneState.loadInProgress() = _LoadInProgress;
  const factory CreateMilestoneState.createMilestoneSuccess() =
      _CreateMilestoneSuccess;
  const factory CreateMilestoneState.createMilestoneFailure({
    required NetworkExceptions error,
  }) = _CreateMilestoneFailure;
}
