import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/project.dart';
import 'package:pma/module/project/project_repository.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

part 'project_state.dart';
part 'project_event.dart';
part 'project_bloc.freezed.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  ProjectBloc({
    required ProjectRepository projectRepository,
  })  : _projectRepository = projectRepository,
        super(const ProjectState.initial()) {
    on<_FetchProject>(_onFetchProject);
  }

  final ProjectRepository _projectRepository;

  FutureOr<void> _onFetchProject(
      _FetchProject event, Emitter<ProjectState> emit) async {
    emit(const _LoadInProgress());
    final ApiResult<Project?> apiResult =
        await _projectRepository.fetchProject(projectId: event.projectId);
    apiResult.when(
      success: (Project? project) {
        if (project == null) {
          emit(const _FetchProjectFailure());
        } else {
          emit(_FetchProjectSuccess(project: project));
        }
      },
      failure: (NetworkExceptions error) {
        emit(const _FetchProjectFailure());
      },
    );
  }
}
