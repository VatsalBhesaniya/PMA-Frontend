import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/project.dart';
import 'package:pma/models/project_detail.dart';
import 'package:pma/module/project_detail/project_detail_repository.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

part 'project_detail_state.dart';
part 'project_detail_event.dart';
part 'project_detail_bloc.freezed.dart';

class ProjectDetailBloc extends Bloc<ProjectDetailEvent, ProjectDetailState> {
  ProjectDetailBloc({
    required ProjectDetailRepository projectDetailRepository,
  })  : _projectDetailRepository = projectDetailRepository,
        super(const ProjectDetailState.initial()) {
    on<_FetchProjectDetail>(_onFetchProjectDetail);
    on<_EditProjectDetail>(_onEditProjectDetail);
    on<_UpdateProjectDetail>(_onUpdateProjectDetail);
    on<_DeleteProject>(_onDeleteProject);
  }

  final ProjectDetailRepository _projectDetailRepository;

  FutureOr<void> _onFetchProjectDetail(
      _FetchProjectDetail event, Emitter<ProjectDetailState> emit) async {
    emit(const _LoadInProgress());
    final ApiResult<ProjectDetail?> apiResult = await _projectDetailRepository
        .fetchProjectDetail(projectId: event.projectId);
    apiResult.when(
      success: (ProjectDetail? projectDetail) {
        if (projectDetail == null) {
          emit(const _FetchProjectDetailFailure(
            error: NetworkExceptions.defaultError(),
          ));
        } else {
          emit(_FetchProjectDetailSuccess(projectDetail: projectDetail));
        }
      },
      failure: (NetworkExceptions error) {
        emit(_FetchProjectDetailFailure(error: error));
      },
    );
  }

  void _onEditProjectDetail(
      _EditProjectDetail event, Emitter<ProjectDetailState> emit) {
    emit(const _LoadInProgress());
    emit(_FetchProjectDetailSuccess(projectDetail: event.projectDetail));
  }

  FutureOr<void> _onUpdateProjectDetail(
      _UpdateProjectDetail event, Emitter<ProjectDetailState> emit) async {
    emit(const _LoadInProgress());
    final Project project = Project(
      id: event.projectDetail.id,
      title: event.projectDetail.title,
      createdBy: event.projectDetail.createdBy,
      createdAt: event.projectDetail.createdAt,
    );
    final ApiResult<bool> apiResult =
        await _projectDetailRepository.updateProjectDetail(project: project);
    apiResult.when(
      success: (bool isProjectUpdated) {
        if (isProjectUpdated) {
          emit(
            _FetchProjectDetailSuccess(
              projectDetail: event.projectDetail,
            ),
          );
        } else {
          emit(const _UpdateProjectDetailFailure());
        }
      },
      failure: (NetworkExceptions error) {
        emit(const _UpdateProjectDetailFailure());
      },
    );
  }

  FutureOr<void> _onDeleteProject(
      _DeleteProject event, Emitter<ProjectDetailState> emit) async {
    emit(const _LoadInProgress());
    final ApiResult<bool> apiResult =
        await _projectDetailRepository.deleteProject(
      projectId: event.projectId,
    );
    apiResult.when(
      success: (bool isDeleted) {
        emit(const _DeleteProjectSuccess());
      },
      failure: (NetworkExceptions error) {
        emit(_DeleteProjectFailure(error: error));
      },
    );
  }
}
