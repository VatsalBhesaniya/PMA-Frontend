import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/create_project.dart';
import 'package:pma/models/project.dart';
import 'package:pma/module/home/projects_repository.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

part 'my_projects_bloc.freezed.dart';
part 'my_projects_event.dart';
part 'my_projects_state.dart';

class MyProjectsBloc extends Bloc<MyProjectsEvent, MyProjectsState> {
  MyProjectsBloc({
    required ProjectsRepository projectsRepository,
  })  : _projectsRepository = projectsRepository,
        super(const MyProjectsState.initial()) {
    on<_FetchProjects>(_onFetchProjects);
    on<_CreateProject>(_onCreateProject);
  }

  final ProjectsRepository _projectsRepository;

  FutureOr<void> _onFetchProjects(
      _FetchProjects event, Emitter<MyProjectsState> emit) async {
    emit(const _LoadInProgress());
    final ApiResult<List<Project>?> apiResult =
        await _projectsRepository.fetchProjects();
    apiResult.when(
      success: (List<Project>? data) {
        emit(
          _FetchProjectsSuccess(
            projects: data ?? <Project>[],
          ),
        );
      },
      failure: (NetworkExceptions error) {
        emit(const _FetchProjectsFailure());
      },
    );
  }

  FutureOr<void> _onCreateProject(
      _CreateProject event, Emitter<MyProjectsState> emit) async {
    final ApiResult<void> apiResult = await _projectsRepository.createProject(
      projectData: event.project.toJson(),
    );
    apiResult.when(
      success: (void result) {
        emit(const _CreateProjectSuccess());
      },
      failure: (NetworkExceptions error) {
        emit(_CreateProjectFailure(error: error));
      },
    );
  }
}
