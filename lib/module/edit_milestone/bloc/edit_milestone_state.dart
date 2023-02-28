part of 'edit_milestone_bloc.dart';

@freezed
class EditMilestoneState with _$EditMilestoneState {
  const factory EditMilestoneState.initial() = _Initial;
  const factory EditMilestoneState.loadInProgress() = _LoadInProgress;
  const factory EditMilestoneState.fetchMilestoneSuccess({
    required Milestone milestone,
  }) = _FetchMilestoneSuccess;
  const factory EditMilestoneState.fetchMilestoneFailure({
    required NetworkExceptions error,
  }) = _FetchMilestoneFailure;
  const factory EditMilestoneState.updateMilestoneSuccess() =
      _UpdateMilestoneSuccess;
  const factory EditMilestoneState.updateMilestoneFailure({
    required NetworkExceptions error,
  }) = _UpdateMilestoneFailure;
  const factory EditMilestoneState.deleteMilestoneSuccess() =
      _DeleteMilestoneSuccess;
  const factory EditMilestoneState.deleteMilestoneFailure({
    required NetworkExceptions error,
  }) = _DeleteMilestoneFailure;
}
